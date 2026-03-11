locals {
  use_vpc        = length(var.subnet_ids) > 0 && length(var.security_group_ids) > 0
  log_group_name = "/aws/lambda/${var.function_name}"

  is_local = var.deployment_mode == "local"
  is_s3    = var.deployment_mode == "s3"
  is_image = var.deployment_mode == "image"
}

# Log Group
resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_log_group ? 1 : 0
  name              = local.log_group_name
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

# Lambda Function
resource "aws_lambda_function" "this" {

  function_name = var.function_name
  role          = var.role_arn

  package_type = local.is_image ? "Image" : "Zip"

  # Runtime/Handler only for Zip mode
  runtime = local.is_image ? null : var.runtime
  handler = local.is_image ? null : var.handler

  timeout       = var.timeout
  memory_size   = var.memory_size
  layers        = var.layers
  architectures = var.architectures

  # Local ZIP
  filename         = local.is_local ? var.filename : null
  source_code_hash = local.is_local ? var.source_code_hash : null

  # S3 Mode
  s3_bucket         = local.is_s3 ? var.s3_bucket : null
  s3_key            = local.is_s3 ? var.s3_key : null
  s3_object_version = local.is_s3 ? var.s3_object_version : null

  # Container Mode
  image_uri = local.is_image ? var.image_uri : null

  # VPC
  dynamic "vpc_config" {
    for_each = local.use_vpc ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  # Environment
  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_cloudwatch_log_group.this
  ]

  tags = merge(var.tags, {
    Name = var.function_name
  })
}
