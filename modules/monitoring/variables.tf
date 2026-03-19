variable "alb_arn_suffix" { type = string }
variable "target_group_arn_suffix" { type = string }
variable "rds_identifier" { type = string }
variable "lambda_name" { type = string }
variable "sqs_queue_name" { type = string }
variable "tags" { type = map(string) }
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}