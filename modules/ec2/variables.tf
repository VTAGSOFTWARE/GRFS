variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "iam_instance_profile" {
  type = string
}
