variable "zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "record_name" {
  description = "DNS name (e.g., uat.example.com)"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
}

variable "cloudfront_hosted_zone_id" {
  description = "CloudFront hosted zone ID"
  type        = string
}