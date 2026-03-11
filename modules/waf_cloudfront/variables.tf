variable "name" { type = string }
variable "description" {
  type    = string
  default = "WAF for CloudFront"
}

variable "rate_limit" {
  type        = number
  default     = 2000
  description = "Requests per 5 minutes per IP"
}

variable "tags" {
  type    = map(string)
  default = {}
}