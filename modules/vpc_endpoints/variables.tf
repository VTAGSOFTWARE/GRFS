variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "route_table_ids" {
  type = list(string)
}

variable "security_group_id" {
  type        = string
  description = "Security group for interface endpoints"
}

variable "region" {
  type = string
}

variable "enable_s3" {
  type    = bool
  default = true
}

variable "enable_sqs" {
  type    = bool
  default = true
}

variable "enable_secretsmanager" {
  type    = bool
  default = true
}

variable "enable_logs" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
