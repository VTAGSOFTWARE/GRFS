variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (must be in us-east-1)"
  type        = string
  default     = null
}

variable "web_acl_arn" {
  description = "WAF Web ACL ARN"
  type        = string
}

variable "aliases" {
  description = "Custom domain aliases"
  type        = list(string)
  default     = []
}

variable "comment" {
  type    = string
  default = "CloudFront Distribution"
}

variable "enable_logging" {
  type    = bool
  default = false
}

variable "logging_bucket" {
  description = "S3 bucket for CloudFront logs"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}