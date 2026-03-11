output "bus_name" {
  value = var.create_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
}

output "rule_arns" {
  value = { for k, v in aws_cloudwatch_event_rule.this : k => v.arn }
}
