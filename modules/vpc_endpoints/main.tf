locals {
  name_prefix = "${var.tags.Project}-${var.tags.Environment}"
}

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  count             = var.enable_s3 ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-s3-endpoint"
  })
}

# Interface Endpoints
resource "aws_vpc_endpoint" "sqs" {
  count               = var.enable_sqs ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-sqs-endpoint"
  })
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count               = var.enable_secretsmanager ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-secrets-endpoint"
  })
}

resource "aws_vpc_endpoint" "logs" {
  count               = var.enable_logs ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-logs-endpoint"
  })
}
