resource "aws_cloudwatch_log_subscription_filter" "cloud_watch_log_group_to_kinesis_subscription_filter" {
  for_each        = var.cloud_watch_ingest_to_elasticsearch_log_groups
  name            = "CMXTrafficCop-${var.environment}-${random_string.upper_case_string[each.key].result}-cloud_watch_log_group_to_kinesis_subscription_filter"
  log_group_name  = each.value.name
  role_arn        = aws_iam_role.cloudwatch_log_access_to_kinesis_stream_role.arn
  filter_pattern  = ""
  destination_arn = aws_kinesis_stream.kinesis_stream_to_push_cloudwatch_log_group_to_es[each.key].arn
  distribution    = var.log_subscription_filter_distribution
  depends_on      = [aws_kinesis_stream.kinesis_stream_to_push_cloudwatch_log_group_to_es]

}
