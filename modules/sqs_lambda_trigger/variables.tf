variable "lambda_function_arn" { type = string }
variable "sqs_queue_arn" { type = string }

variable "enabled" {
  type    = bool
  default = true
}
variable "batch_size" {
  type    = number
  default = 10
}
variable "maximum_batching_window_in_seconds" {
  type    = number
  default = 0
}

variable "maximum_concurrency" {
  type        = number
  default     = null
  description = "Optional scaling_config.maximum_concurrency"
}
