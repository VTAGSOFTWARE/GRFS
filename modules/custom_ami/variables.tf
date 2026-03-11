variable "name_prefix" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "use_custom_ami" {
  type    = bool
  default = false
}