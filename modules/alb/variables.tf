variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "target_port" {
  type        = number
  description = "Application backend port"
  default     = 8080
}

variable "health_check_path" {
  type        = string
  description = "Health check endpoint path"
  default     = "/health"
}

variable "internal" {
  type        = bool
  description = "Whether ALB is internal"
  default     = false
}

variable "enable_deletion_protection" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "target_type" {
  type        = string
  description = "Target type: instance | ip | lambda"
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip", "lambda"], var.target_type)
    error_message = "target_type must be one of: instance, ip, lambda."
  }
}


variable "enable_https" {
  type    = bool
  default = false
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "api_host_name" {
  type    = string
  default = ""
}

variable "api_target_port" {
  type    = number
  default = 8080
}