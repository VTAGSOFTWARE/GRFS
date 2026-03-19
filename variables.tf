variable "aws_profile" {
  description = "AWS profile"
  type        = string
}

variable "region" {
  type        = string
  description = "Region where resources will be deployed"
  default     = "ap-south-1"
}

variable "project_name" {
  type        = string
  description = "Project name"
  default     = "grp"
}

variable "environment" {
  type        = string
  description = "Environment Name"
  default     = "uat"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR range"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDR"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDR"
}

variable "isolated_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDR"
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "storage_type" {
  type    = string
  default = "gp3"
}

##variable "acm_certificate_arn" {
##  type        = string
##  description = "ACM certificate ARN for ALB HTTPS listener."
##}

variable "target_type" {
  type        = string
  description = "Target type: instance | ip | lambda"
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip", "lambda"], var.target_type)
    error_message = "target_type must be one of: instance, ip, lambda."
  }
}

variable "ami_name_filter" {
  type        = string
  description = "AMI name pattern filter"
  default     = "al2023-ami-*-x86_64"
}

variable "ami_owner" {
  type        = string
  description = "AMI owner"
  default     = "amazon"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3a.medium"
}

variable "compute_mode" {
  type    = string
  default = "ec2"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "bucket_suffix" {
  description = "Suffix for bucket (e.g. uploads, logs)"
  type        = string
  default     = "uploads"
}

variable "db_username" {
  type    = string
  default = "grpadmin"
}

variable "db_name" {
  type    = string
  default = "grpdb"
}

variable "kyc_lambda_zip_path" {
  type        = string
  description = "Path to lambda deployment zip"
  default     = "artifacts/kyc_lambda.zip"
}

variable "kyc_lambda_runtime" {
  type    = string
  default = "python3.12"
}

variable "kyc_lambda_handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "kyc_lambda_timeout" {
  type    = number
  default = 30
}

variable "kyc_lambda_memory" {
  type    = number
  default = 512
}

variable "enable_https" {
  type    = bool
  default = false
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "api_host_name" {
  type    = string
  default = ""
}

variable "api_target_port" {
  type    = number
  default = 8080
}

variable "ami_id" {
  description = "Explicit AMI ID override (env-specific)"
  type        = string
  default     = null
}

##variable "amplify_repository_url" {
##  type        = string
##  description = "Frontend repo URL"
##}
##
##variable "amplify_oauth_token" {
##  type        = string
##  description = "OAuth token for repo access (store securely)"
##  sensitive   = true
##}
##
##variable "amplify_branch_name" {
##  type    = string
##  default = "main"
##}

variable "cloudfront_acm_certificate_arn" {
  description = "ACM cert ARN in us-east-1"
  type        = string
}

variable "app_domain" {
  description = "Public domain for CloudFront"
  type        = string
}

variable "route53_zone_id" {
  description = "Hosted Zone ID"
  type        = string
}

variable "file_scanner_lambda_zip_path" {
  type        = string
  description = "Path to file scanner lambda zip"
  default     = "artifacts/file_scanner_lambda.zip"
}

variable "integration_lambda_zip_path" {
  type        = string
  description = "Path to integration lambda zip"
  default     = "artifacts/integration_lambda.zip"
}

variable "use_custom_ami" {
  description = "Custom AMI"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.large"
}

variable "db_multi_az" {
  type    = bool
  default = true
}

variable "db_backup_retention" {
  type    = number
  default = 7
}

variable "db_backup_window" {
  type    = string
  default = "03:00-04:00"
}

variable "db_maintenance_window" {
  type    = string
  default = "sun:04:00-sun:05:00"
}

variable "root_volume_size" {
  type    = number
  default = 30
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "root_volume_encrypted" {
  type    = bool
  default = true
}
