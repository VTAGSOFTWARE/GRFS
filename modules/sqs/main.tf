locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  name                      = "${local.name_prefix}-${var.queue_name}-dlq"
  message_retention_seconds = var.dlq_retention_seconds
  kms_master_key_id         = "alias/aws/sqs"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-${var.queue_name}-dlq"
  })
}

# Main Queue
resource "aws_sqs_queue" "main" {
  name                       = "${local.name_prefix}-${var.queue_name}"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  kms_master_key_id          = "alias/aws/sqs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-${var.queue_name}"
  })
}
