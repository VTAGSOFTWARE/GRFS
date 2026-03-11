locals {
  name_prefix = "${var.project_name}-${var.environment}"
  secret_name = "${local.name_prefix}-${var.secret_suffix}"
}

resource "random_password" "this" {
  length           = var.password_length
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "this" {
  name                    = local.secret_name
  description             = var.description
  recovery_window_in_days = var.recovery_window_in_days

  kms_key_id = var.kms_key_id

  tags = merge(var.tags, {
    Name = local.secret_name
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id

  secret_string = jsonencode(merge(
    var.static_kv,
    {
      username = var.db_username
      password = random_password.this.result
    }
  ))
}
