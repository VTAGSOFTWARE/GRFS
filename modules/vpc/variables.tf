variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "isolated_subnet_cidrs" {
  type    = list(string)
  default = []
}

# Optional toggles
variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

# If true, create only 1 NAT gateway in first public subnet.
# If false, create 1 NAT per AZ (recommended for prod).
variable "single_nat_gateway" {
  type    = bool
  default = false
}

# Optional: turn on VPC flow logs later
variable "enable_flow_logs" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
