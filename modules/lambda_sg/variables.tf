variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

variable "egress_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Outbound CIDRs"
}

variable "ingress_rules" {
  description = "Optional ingress rules (usually empty for Lambda)"
  type = list(object({
    description        = optional(string)
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = optional(list(string))
    security_group_ids = optional(list(string))
  }))
  default = []
}
