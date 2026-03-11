variable "project_name" { type = string }
variable "environment" { type = string }

variable "secret_suffix" {
  type        = string
  description = "Suffix for secret name, e.g. db-credentials"
  default     = "db-credentials"
}

variable "description" {
  type    = string
  default = "Managed by Terraform"
}

variable "recovery_window_in_days" {
  type    = number
  default = 7
}

variable "kms_key_id" {
  type        = string
  description = "Optional CMK ARN for secret encryption. If null, AWS managed key is used."
  default     = null
}

variable "db_username" {
  type        = string
  description = "Database username to store in secret"
}

variable "password_length" {
  type    = number
  default = 20
}

variable "static_kv" {
  type        = map(any)
  description = "Extra static key-values to store in secret (host, port, dbname, etc.)"
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
