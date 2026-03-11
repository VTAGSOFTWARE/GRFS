output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "backend_sg_id" {
  value = aws_security_group.backend.id
}

output "lambda_sg_id" {
  value = aws_security_group.lambda.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

output "vpc_endpoint_sg_id" {
  value = aws_security_group.vpc_endpoint.id
}
