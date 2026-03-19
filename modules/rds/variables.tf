variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "db_name" {
  type    = string
  default = "grpdb"
}

variable "db_username" {
  type    = string
  default = "grpadmin"
}

variable "engine_version" {
  type    = string
  default = "17.4"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.small"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "max_allocated_storage" {
  type    = number
  default = 1000
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "storage_type" {
  type        = string
  default     = "gp3"
  description = "Type of storage"
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "backup_window" {
  type    = string
  default = "03:00-04:00"
}

variable "maintenance_window" {
  type    = string
  default = "sun:04:00-sun:05:00"
}
