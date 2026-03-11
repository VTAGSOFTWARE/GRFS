locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "vpc" {

  source = "./modules/vpc"

  name = "${var.project_name}-${var.environment}"

  cidr = var.vpc_cidr

  azs = var.azs

  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  isolated_subnet_cidrs = var.isolated_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "security" {

  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "rds" {

  source = "./modules/rds"

  project_name = var.project_name
  environment  = var.environment

  subnet_ids        = module.vpc.isolated_subnet_ids
  security_group_id = module.security.rds_sg_id
  storage_type      = var.storage_type

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "ec2_ssm" {
  source = "./modules/ec2-ssm"

  project_name = var.project_name
  environment  = var.environment
}

module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id

  target_type       = var.target_type
  target_port       = 8080
  health_check_path = "/graphql"

  internal = false

  enable_https        = var.enable_https
  acm_certificate_arn = var.acm_certificate_arn
  api_host_name       = var.api_host_name
  api_target_port     = var.api_target_port


  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "launch_template" {
  source = "./modules/launch_template"

  project_name = var.project_name
  environment  = var.environment

  instance_type         = var.instance_type
  security_group_id     = module.security.backend_sg_id
  instance_profile_name = module.ec2_ssm.instance_profile_name

  compute_mode     = var.compute_mode
  ecs_cluster_name = "${var.project_name}-${var.environment}-ecs"

  ami_id = var.use_custom_ami ? module.custom_ami.ami_id : var.ami_id

  user_data_extra = <<-EOF
#!/bin/bash

# Ensure docker running
systemctl start docker
systemctl enable docker

# Login to ECR
aws ecr get-login-password --region ${var.region} | \
docker login --username AWS --password-stdin 853715068886.dkr.ecr.${var.region}.amazonaws.com

# Get image version from SSM
IMAGE_TAG=$(aws ssm get-parameter \
  --name "/app/${var.environment}/image_tag" \
  --region ${var.region} \
  --query Parameter.Value \
  --output text)

# Pull image
docker pull 853715068886.dkr.ecr.${var.region}.amazonaws.com/grp-api-${var.environment}:$IMAGE_TAG

# Run container
docker run -d \
  --name GRP-API \
  -p 8080:5050 \
  --restart unless-stopped \
  853715068886.dkr.ecr.${var.region}.amazonaws.com/grp-api-${var.environment}:$IMAGE_TAG
EOF

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "autoscaling" {
  source = "./modules/autoscaling"

  project_name = var.project_name
  environment  = var.environment

  launch_template_id = module.launch_template.launch_template_id
  private_subnet_ids = module.vpc.private_subnet_ids
  target_group_arn   = module.alb.target_group_arn

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "uploads_bucket" {
  source = "./modules/s3"

  project_name  = var.project_name
  environment   = var.environment
  bucket_suffix = var.bucket_suffix

  enable_versioning = true
  enable_kms        = false
  enable_lifecycle  = false

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "campaign_queue" {
  source = "./modules/sqs"

  project_name = var.project_name
  environment  = var.environment
  queue_name   = "campaign"

  visibility_timeout_seconds = 60
  max_receive_count          = 5

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "db_secret" {
  source = "./modules/secrets_manager"

  project_name = var.project_name
  environment  = var.environment

  secret_suffix = "postgres-credentials"
  db_username   = var.db_username

  static_kv = {
    engine = "postgres"
    host   = module.rds.endpoint
    port   = 5432
    dbname = var.db_name
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_policy" "read_db_secret" {
  name        = "${var.project_name}-${var.environment}-read-db-secret"
  description = "Allow EC2 instances to read DB secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = module.db_secret.secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_read_secret" {
  role       = module.ec2_ssm.role_name
  policy_arn = aws_iam_policy.read_db_secret.arn
}

module "eventbridge" {
  source      = "./modules/eventbridge"
  name_prefix = local.name_prefix
  create_bus  = false
  rules       = {}
  tags        = local.common_tags
}

# 2) Lambda IAM Role
module "kyc_lambda_iam" {
  source            = "./modules/lambda_iam"
  name_prefix       = "${local.name_prefix}-kyc"
  enable_vpc_access = true
  extra_policy_arns = []

  inline_policy_json = null
  sqs_queue_arn      = module.campaign_queue.queue_arn

  tags = local.common_tags
}

# 3) Lambda Security Group
module "kyc_lambda_sg" {
  source        = "./modules/lambda_sg"
  name_prefix   = "${local.name_prefix}-kyc"
  vpc_id        = module.vpc.vpc_id
  tags          = local.common_tags
  ingress_rules = []
}

# 4) Lambda Function
module "kyc_lambda" {
  depends_on = [
    module.kyc_lambda_iam
  ]
  source        = "./modules/lambda"
  name_prefix   = "${local.name_prefix}-kyc"
  function_name = "${local.name_prefix}-kyc-handler"

  role_arn    = module.kyc_lambda_iam.role_arn
  runtime     = var.kyc_lambda_runtime
  handler     = var.kyc_lambda_handler
  timeout     = var.kyc_lambda_timeout
  memory_size = var.kyc_lambda_memory

  # placeholder zip (team can replace later)
  filename         = var.kyc_lambda_zip_path
  source_code_hash = filebase64sha256(var.kyc_lambda_zip_path)

  # 5) Lambda VPC config
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.kyc_lambda_sg.security_group_id]

  environment_variables = {
    ENV = var.environment
    # Later: DB endpoint, secret ARN, etc.
  }

  log_retention_in_days = 14
  tags                  = local.common_tags
}

# 6) SQS Lambda trigger wiring
module "kyc_sqs_trigger" {
  source              = "./modules/sqs_lambda_trigger"
  lambda_function_arn = module.kyc_lambda.function_arn
  sqs_queue_arn       = module.campaign_queue.queue_arn

  enabled                            = true
  batch_size                         = 10
  maximum_batching_window_in_seconds = 5
  maximum_concurrency                = 5
}

resource "aws_guardduty_detector" "this" {
  enable = true
}

module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  route_table_ids    = module.vpc.private_route_table_ids
  security_group_id  = module.security.vpc_endpoint_sg_id
  region             = var.region

  tags = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  rds_identifier          = module.rds.db_instance_identifier
  lambda_name             = module.kyc_lambda.function_name
  sqs_queue_name          = module.campaign_queue.queue_name
  tags                    = local.common_tags
}

##New Code
##module "amplify" {
##  source = "./modules/amplify"
##
##  app_name       = "${local.name_prefix}-frontend"
##  repository_url = var.amplify_repository_url
##  oauth_token    = var.amplify_oauth_token
##  branch_name    = var.amplify_branch_name
##
##  enable_auto_build = true
##
##  environment_variables = {
##    ENV = var.environment
##  }
##
##  # Optional: if you want branch-specific ENV vars
##  branch_environment_variables = {
##    REACT_APP_ENV = var.environment
##  }
##
##  tags = local.common_tags
##}

module "waf_cloudfront" {
  source = "./modules/waf_cloudfront"

  providers = {
    aws = aws.us_east_1
  }

  name        = "${local.name_prefix}-cf-waf"
  description = "CloudFront WAF for ${local.name_prefix}"
  rate_limit  = 2000

  tags = local.common_tags
}

module "cloudfront" {
  source = "./modules/cloudfront"

  providers = { aws = aws.us_east_1 }

  alb_dns_name        = module.alb.alb_dns_name
  acm_certificate_arn = var.cloudfront_acm_certificate_arn
  web_acl_arn         = module.waf_cloudfront.web_acl_arn

  aliases = var.cloudfront_acm_certificate_arn == null ? [] : ["uat.goldenrichproperties.com"]

  tags = local.common_tags
}

##module "route53" {
##  source = "./modules/route53"
##
##  zone_id                   = var.route53_zone_id
##  record_name               = var.app_domain
##  cloudfront_domain_name    = module.cloudfront.domain_name
##  cloudfront_hosted_zone_id = module.cloudfront.hosted_zone_id
##}

module "file_scanner_lambda_iam" {
  source            = "./modules/lambda_iam"
  name_prefix       = "${local.name_prefix}-file-scan"
  enable_vpc_access = true

  sqs_queue_arn     = null
  extra_policy_arns = []

  tags = local.common_tags
}

module "file_scanner_lambda_sg" {
  source      = "./modules/lambda_sg"
  name_prefix = "${local.name_prefix}-file-scan"
  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags

  ingress_rules = []
}

module "file_scanner_lambda" {
  depends_on = [module.file_scanner_lambda_iam]

  source        = "./modules/lambda"
  name_prefix   = "${local.name_prefix}-file-scan"
  function_name = "${local.name_prefix}-file-scanner"

  role_arn    = module.file_scanner_lambda_iam.role_arn
  runtime     = "python3.12"
  handler     = "lambda_function.lambda_handler"
  timeout     = 60
  memory_size = 512

  filename         = var.file_scanner_lambda_zip_path
  source_code_hash = filebase64sha256(var.file_scanner_lambda_zip_path)

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.file_scanner_lambda_sg.security_group_id]

  environment_variables = {
    ENV = var.environment
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_notification" "uploads_notification" {
  bucket = module.uploads_bucket.bucket_name

  lambda_function {
    lambda_function_arn = module.file_scanner_lambda.function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    module.file_scanner_lambda
  ]
}

resource "aws_lambda_permission" "allow_s3_invoke_file_scanner" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = module.file_scanner_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.uploads_bucket.bucket_arn
}

module "integration_lambda_iam" {
  source            = "./modules/lambda_iam"
  name_prefix       = "${local.name_prefix}-integration"
  enable_vpc_access = true
  sqs_queue_arn     = null
  tags              = local.common_tags
}

module "integration_lambda_sg" {
  source        = "./modules/lambda_sg"
  name_prefix   = "${local.name_prefix}-integration"
  vpc_id        = module.vpc.vpc_id
  tags          = local.common_tags
  ingress_rules = []
}

module "integration_lambda" {
  depends_on = [module.integration_lambda_iam]

  source        = "./modules/lambda"
  name_prefix   = "${local.name_prefix}-integration"
  function_name = "${local.name_prefix}-integration-adapter"

  role_arn    = module.integration_lambda_iam.role_arn
  runtime     = "python3.12"
  handler     = "lambda_function.lambda_handler"
  timeout     = 60
  memory_size = 512

  filename         = var.integration_lambda_zip_path
  source_code_hash = filebase64sha256(var.integration_lambda_zip_path)

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.integration_lambda_sg.security_group_id]

  environment_variables = {
    ENV = var.environment
  }

  tags = local.common_tags
}

module "custom_ami" {
  source      = "./modules/custom_ami"
  name_prefix = local.name_prefix

  subnet_id         = module.vpc.private_subnet_ids[0]
  security_group_id = module.security.backend_sg_id

  use_custom_ami = var.use_custom_ami
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_read" {
  role       = module.ec2_ssm.role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy" "ec2_ssm_read_param" {
  name = "${var.project_name}-${var.environment}-ssm-read-param"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:${var.region}:853715068886:parameter/app/${var.environment}/image_tag"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_read_param_attach" {
  role       = module.ec2_ssm.role_name
  policy_arn = aws_iam_policy.ec2_ssm_read_param.arn
}