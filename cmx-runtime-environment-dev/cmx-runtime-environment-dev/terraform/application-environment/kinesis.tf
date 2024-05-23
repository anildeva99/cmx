resource "aws_kinesis_stream" "kinesis_stream_to_push_cloudwatch_log_group_to_es" {
  for_each = var.cloud_watch_ingest_to_elasticsearch_log_groups
  name     = "CMXApplication-${var.environment}-${random_string.upper_case_string[each.key].result}-kinesis_stream_to_${each.value.log_template_name}"

  shard_count      = each.value.kinesis_shard_count
  retention_period = var.kinesis_rentention_period
  encryption_type  = "KMS"
  kms_key_id       = var.kinesis_stream_kms_key_alias

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "kinesis_stream_to_push_cloudwatch_log_group_to_es"
      Name = "CodaMetrix Kinesis - kinesis_stream_to_push_cloudwatch_log_group_to_es"
    }
  )
}
