locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_secretsmanager_secret" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-credentials"
  description = "Database secret"
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    endpoint = aws_db_instance.this.endpoint
  })
}

# Generate Random Password
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "_%@"
}

# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

# RDS PostgreSQL
resource "aws_db_instance" "this" {

  identifier        = "${local.name_prefix}-postgres"
  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  storage_type = var.storage_type
  ##iops                  = 3000
  ##storage_throughput    = 125
  max_allocated_storage = var.max_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  multi_az            = var.multi_az
  publicly_accessible = false

  storage_encrypted = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  skip_final_snapshot = false
  deletion_protection = true

  final_snapshot_identifier = "${local.name_prefix}-final-snapshot"
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window

  enabled_cloudwatch_logs_exports = ["postgresql"]
  auto_minor_version_upgrade      = true
  tags = merge(var.tags, {
    Name = "${local.name_prefix}-postgres"
  })
}
