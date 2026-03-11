region       = "ap-south-1"
aws_profile  = "grp-uat"
project_name = "grp"
environment  = "uat"

vpc_cidr = "10.20.0.0/16"

azs = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.20.0.0/24",
  "10.20.1.0/24"
]

private_subnet_cidrs = [
  "10.20.10.0/24",
  "10.20.11.0/24"
]

isolated_subnet_cidrs = [
  "10.20.20.0/24",
  "10.20.21.0/24"
]

enable_nat_gateway = true
single_nat_gateway = true

#acm_certificate_arn = "arn:aws:acm:ap-south-1:ACCOUNT_ID:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

kyc_lambda_zip_path = "artifacts/kyc_lambda.zip"
kyc_lambda_runtime  = "python3.12"
kyc_lambda_handler  = "lambda_function.lambda_handler"
kyc_lambda_timeout  = 30
kyc_lambda_memory   = 512

enable_https = true

acm_certificate_arn = "arn:aws:acm:ap-south-1:853715068886:certificate/02bf1464-56f0-4f1d-be0f-145d980eceb7"

api_host_name   = "uat-api.goldenrichproperties.com"
api_target_port = 8080

ami_id = "ami-0d943fe564cba50c8"

#amplify_repository_url = "https://github.com/<org>/<repo>"
#amplify_oauth_token    = "<PUT_TOKEN_HERE>"
#amplify_branch_name    = "main"

route53_zone_id = "Z123456ABCDEFG"
app_domain      = "uat.goldenrichproperties.com"

cloudfront_acm_certificate_arn = "arn:aws:acm:us-east-1:853715068886:certificate/6842328d-6cf9-4160-9446-f47b6f586ee7"

use_custom_ami = true