variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "compute_mode" {
  type        = string
  description = "ec2 or ecs"
  default     = "ec2"

  validation {
    condition     = contains(["ec2", "ecs"], var.compute_mode)
    error_message = "compute_mode must be ec2 or ecs."
  }
}

variable "ecs_cluster_name" {
  type    = string
  default = ""
}

variable "user_data_extra" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ami_name_filter" {
  type    = string
  default = "al2023-ami-*-x86_64"
}

variable "ami_owner" {
  type    = string
  default = "amazon"
}

variable "ami_id" {
  description = "Optional explicit AMI ID"
  type        = string
  default     = null
}
