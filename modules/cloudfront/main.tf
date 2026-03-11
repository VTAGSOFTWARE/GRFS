resource "aws_cloudfront_distribution" "this" {

  enabled             = true
  comment             = var.comment
  default_root_object = "index.html"

  aliases = var.aliases
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET", "HEAD", "OPTIONS",
      "PUT", "POST", "PATCH", "DELETE"
    ]

    cached_methods = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }
  }

  ##viewer_certificate {
  ##  acm_certificate_arn      = var.acm_certificate_arn
  ##  ssl_support_method       = "sni-only"
  ##  minimum_protocol_version = "TLSv1.2_2021"
  ##}
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == null ? true : false
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn == null ? null : "sni-only"
    minimum_protocol_version       = var.acm_certificate_arn == null ? null : "TLSv1.2_2021"
  }

  # Attach WAF
  web_acl_id = var.web_acl_arn

  # No geo restriction
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []
    content {
      include_cookies = false
      bucket          = var.logging_bucket
      prefix          = "cloudfront/"
    }
  }

  tags = var.tags
}