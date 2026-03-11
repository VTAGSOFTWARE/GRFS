variable "name_prefix" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_vpc_access" {
  type        = bool
  default     = true
  description = "Attach AWSLambdaVPCAccessExecutionRole"
}

variable "extra_policy_arns" {
  type        = list(string)
  default     = []
  description = "Extra managed policy ARNs to attach"
}

variable "inline_policy_json" {
  type        = string
  default     = null
  description = "Optional inline policy JSON"
}

variable "sqs_queue_arn" {
  type    = string
  default = null
}
