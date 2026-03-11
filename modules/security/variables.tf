variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_ingress_cidr" {
  description = "CIDR allowed to access ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Application port used by backend EC2"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "tags" {
  type    = map(string)
  default = {}
}
