resource "aws_cloudwatch_log_group" "application_elasticsearch_domain_cwlog_group" {
  name       = "CodaMetrixApplication-${var.environment}-application_elasticsearch_domain_cwlog_group"
  kms_key_id = aws_kms_key.application_cloudwatch_logs_kms_key.arn

  tags = merge(
    var.shared_resource_tags,
    {
      Type   = "application_elasticsearch_domain_cwlog_group"
      Name   = "CodaMetrix Application Cloudwatch Log Group - application_elasticsearch_domain_cwlog_group"
      Domain = "CodaMetrixApplication-${var.environment}-application_elasticsearch_domain_cwlog_group"
    }
  )
}

resource "aws_cloudwatch_log_resource_policy" "application_elasticsearch_domain_cwlog_policy" {
  policy_name = aws_cloudwatch_log_group.application_elasticsearch_domain_cwlog_group.name

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

# Cloudwatch logging group for Kinesis Firehose that process cw log group to es
resource "aws_cloudwatch_log_group" "cloud_watch_ingest_to_es_by_kinesis_firehose_log_group" {
  for_each          = var.cloud_watch_ingest_to_elasticsearch_log_groups
  name              = "/aws/firehose/CMXApplication-${var.environment}-${random_string.upper_case_string[each.key].result}-cloud_watch_ingest_to_es_by_kinesis_firehose_log_group"
  retention_in_days = var.firehose_cloudwatch_log_retention

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "cloud_watch_ingest_to_es_by_kinesis_firehose_log_group"
      Name = "CodaMetrix Application CloudWatch - cloud_watch_ingest_to_es_by_kinesis_firehose_log_group"
    }
  )
}

resource "aws_cloudwatch_event_rule" "execution_interval_to_fire_lambda_function_take_snapshot" {
  for_each            = var.elasticsearch_index_rotation
  # name can not be longer than 64 characters
  name                = "CMXApp-${var.environment}-${each.key}-interval_to_take_snapshot"
  description         = "Fires lambda function according to ${each.key} cron schedule"
  schedule_expression = each.value.cron_schedule_for_snapshot
}

resource "aws_cloudwatch_event_rule" "execution_interval_to_fire_lambda_function_delete_indices" {
  for_each            = var.elasticsearch_index_rotation
  # name can not be longer than 64 characters
  name                = "CMXApp-${var.environment}-${each.key}-interval_to_delete_indices"
  description         = "Fires lambda function according to ${each.key} cron schedule"
  schedule_expression = each.value.cron_schedule_for_deleting_indices
}

resource "aws_cloudwatch_event_target" "snapshot_elasticsearch_to_fire_lambda_function" {
  for_each  = var.elasticsearch_index_rotation
  rule      = aws_cloudwatch_event_rule.execution_interval_to_fire_lambda_function_take_snapshot[each.key].name
  target_id = "${each.key}_es_take_snapshots_and_rotate_indices_lambda"
  arn       = aws_lambda_function.elasticsearch_rotate_indices[each.key].arn
  input     = <<EOF
{
  "env": "${var.environment}",
  "indices_to_delete": "${var.elasticsearch_index_rotation[each.key].indices}",
  "es_domain_name": "${var.elasticsearch_index_rotation[each.key].domain_address}",
  "es_repository_name": "${var.elasticsearch_index_rotation[each.key].bucket}",
  "region": "${var.aws_region}",
  "action": "take_snapshot"
}
EOF
}

resource "aws_cloudwatch_event_target" "elasticsearch_delete_index_to_fire_lambda_function" {
  for_each = var.elasticsearch_index_rotation
  rule      = aws_cloudwatch_event_rule.execution_interval_to_fire_lambda_function_delete_indices[each.key].name
  target_id = "${each.key}_es_rotate_indices_lambda"
  arn       = aws_lambda_function.elasticsearch_rotate_indices[each.key].arn
  input     = <<EOF
{
  "env": "${var.environment}",
  "indices_to_delete": "${var.elasticsearch_index_rotation[each.key].indices}",
  "es_domain_name": "${var.elasticsearch_index_rotation[each.key].domain_address}",
  "es_repository_name": "${var.elasticsearch_index_rotation[each.key].bucket}",
  "region": "${var.aws_region}",
  "action": "delete_indices"
}
EOF
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_es_to_take_snapshot" {
  for_each = var.elasticsearch_index_rotation
  statement_id  = "CMXApplication-${var.environment}-${each.key}-allow_cloudwatch_to_call_es_to_take_snapshot"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.elasticsearch_rotate_indices[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.execution_interval_to_fire_lambda_function_take_snapshot[each.key].arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_es_to_rotate_indices" {
  for_each = var.elasticsearch_index_rotation
  statement_id  = "CMXApplication-${var.environment}-${each.key}-allow_cloudwatch_to_call_es_to_rotate_indices"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.elasticsearch_rotate_indices[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.execution_interval_to_fire_lambda_function_delete_indices[each.key].arn
}
