variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "bucket_suffix" {
  description = "Suffix for bucket (e.g. uploads, logs)"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket deletion even if not empty"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "enable_kms" {
  type    = bool
  default = false
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "Optional KMS key ARN"
}

variable "enable_lifecycle" {
  type    = bool
  default = false
}

variable "lifecycle_expiration_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
