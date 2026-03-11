variable "app_name" { type = string }

variable "repository_url" {
  type        = string
  description = "Git repo URL (e.g., https://github.com/org/repo)"
}

variable "oauth_token" {
  type        = string
  description = "Git provider OAuth token (store in TFVARS/Secrets Manager/CI secret)"
  sensitive   = true
}

variable "branch_name" {
  type    = string
  default = "main"
}

variable "framework" {
  type    = string
  default = "React"
}

variable "stage" {
  type        = string
  default     = "PRODUCTION"
  description = "PRODUCTION | BETA | DEVELOPMENT | EXPERIMENTAL"
}

variable "enable_auto_build" {
  type    = bool
  default = true
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "branch_environment_variables" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}