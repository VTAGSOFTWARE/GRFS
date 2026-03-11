locals {
  bus_name_effective = var.create_bus ? var.bus_name : "default"
}

# Event Bus (optional)
resource "aws_cloudwatch_event_bus" "this" {
  count = var.create_bus ? 1 : 0
  name  = var.bus_name
  tags  = var.tags
}

# Event Rules
resource "aws_cloudwatch_event_rule" "this" {
  for_each = var.rules

  name        = "${var.name_prefix}-${each.key}"
  description = try(each.value.description, null)

  event_bus_name = local.bus_name_effective

  # Only one of these should be set
  event_pattern       = try(each.value.event_pattern, null)
  schedule_expression = try(each.value.schedule_expression, null)

  is_enabled = try(each.value.enabled, true)

  tags = var.tags
}

# Event Targets (flattened)
resource "aws_cloudwatch_event_target" "targets" {
  for_each = {
    for x in flatten([
      for rule_key, rule in var.rules : [
        for t in try(rule.targets, []) : {
          rule_key          = rule_key
          id                = t.id
          arn               = t.arn
          role_arn          = try(t.role_arn, null)
          input             = try(t.input, null)
          input_path        = try(t.input_path, null)
          input_transformer = try(t.input_transformer, null)
          dead_letter_arn   = try(t.dead_letter_arn, null)
          retry_policy      = try(t.retry_policy, null)
        }
      ]
    ]) : "${x.rule_key}::${x.id}" => x
  }

  event_bus_name = local.bus_name_effective
  rule           = aws_cloudwatch_event_rule.this[each.value.rule_key].name

  target_id = each.value.id
  arn       = each.value.arn
  role_arn  = each.value.role_arn

  input      = each.value.input
  input_path = each.value.input_path

  # Optional: Input Transformer
  dynamic "input_transformer" {
    for_each = each.value.input_transformer == null ? [] : [each.value.input_transformer]
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  # Optional: Dead Letter Queue
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_arn == null ? [] : [each.value.dead_letter_arn]
    content {
      arn = dead_letter_config.value
    }
  }

  # Optional: Retry Policy
  dynamic "retry_policy" {
    for_each = each.value.retry_policy == null ? [] : [each.value.retry_policy]
    content {
      maximum_event_age_in_seconds = try(retry_policy.value.maximum_event_age_in_seconds, null)
      maximum_retry_attempts       = try(retry_policy.value.maximum_retry_attempts, null)
    }
  }
}
