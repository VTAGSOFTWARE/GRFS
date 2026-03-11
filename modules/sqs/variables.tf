variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "queue_name" {
  type        = string
  description = "Base name of the queue"
}

variable "visibility_timeout_seconds" {
  type    = number
  default = 30
}

variable "message_retention_seconds" {
  type    = number
  default = 345600 # 4 days
}

variable "dlq_retention_seconds" {
  type    = number
  default = 1209600 # 14 days
}

variable "max_receive_count" {
  type    = number
  default = 5
}

variable "receive_wait_time_seconds" {
  type    = number
  default = 20 # long polling enabled
}

variable "tags" {
  type    = map(string)
  default = {}
}
