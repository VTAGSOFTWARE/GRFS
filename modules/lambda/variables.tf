variable "name_prefix" {
  type = string
}

variable "function_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "role_arn" {
  type = string
}

# Deployment Mode
variable "deployment_mode" {
  description = "local | s3 | image"
  type        = string
  default     = "local"

  validation {
    condition     = contains(["local", "s3", "image"], var.deployment_mode)
    error_message = "deployment_mode must be one of: local, s3, image."
  }
}

# Local ZIP Mode
variable "filename" {
  type        = string
  default     = null
  description = "Local zip file path (used when deployment_mode = local)"
}

variable "source_code_hash" {
  type        = string
  default     = null
  description = "Required when using filename"
}

# S3 Artifact Mode
variable "s3_bucket" {
  type    = string
  default = null
}

variable "s3_key" {
  type    = string
  default = null
}

variable "s3_object_version" {
  type    = string
  default = null
}

# Container Image Mode
variable "image_uri" {
  type    = string
  default = null
}

# Runtime Config
variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 512
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "layers" {
  type    = list(string)
  default = []
}

variable "architectures" {
  type    = list(string)
  default = ["x86_64"]
}

# VPC Config
variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

# Logging
variable "create_log_group" {
  type    = bool
  default = true
}

variable "log_retention_in_days" {
  type    = number
  default = 14
}
