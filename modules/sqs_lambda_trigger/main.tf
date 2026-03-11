resource "aws_lambda_event_source_mapping" "this" {
  event_source_arn = var.sqs_queue_arn
  function_name    = var.lambda_function_arn

  enabled                            = var.enabled
  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds

  dynamic "scaling_config" {
    for_each = var.maximum_concurrency == null ? [] : [1]
    content {
      maximum_concurrency = var.maximum_concurrency
    }
  }
}
