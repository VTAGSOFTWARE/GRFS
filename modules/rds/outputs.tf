output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_identifier" {
  value = aws_db_instance.this.id
}

output "db_username" {
  value = var.db_username
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "db_instance_identifier" {
  value = aws_db_instance.this.id
}
