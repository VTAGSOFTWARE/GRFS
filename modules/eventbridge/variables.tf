variable "name_prefix" {
  type        = string
  description = "Prefix for EventBridge resources"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags"
}

variable "create_bus" {
  type        = bool
  default     = false
  description = "If true, create a custom event bus. Otherwise uses default bus."
}

variable "bus_name" {
  type        = string
  default     = null
  description = "Custom event bus name (required if create_bus=true)"
}

variable "rules" {
  description = "Map of rules with either event_pattern or schedule_expression plus optional targets"
  type = map(object({
    description         = optional(string)
    enabled             = optional(bool, true)
    event_pattern       = optional(string) # JSON string
    schedule_expression = optional(string) # e.g. rate(5 minutes) or cron(...)
    targets = optional(list(object({
      id  = string
      arn = string

      role_arn   = optional(string)
      input      = optional(string)
      input_path = optional(string)

      # optional input transformer
      input_transformer = optional(object({
        input_paths    = map(string)
        input_template = string
      }))

      # optional retry / DLQ
      dead_letter_arn = optional(string)
      retry_policy = optional(object({
        maximum_event_age_in_seconds = optional(number)
        maximum_retry_attempts       = optional(number)
      }))
    })), [])
  }))

  default = {}
}
