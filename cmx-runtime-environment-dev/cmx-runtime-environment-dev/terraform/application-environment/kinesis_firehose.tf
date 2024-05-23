resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_to_es" {
  for_each    = var.cloud_watch_ingest_to_elasticsearch_log_groups
  # The name can not be longer than 64 characters, so take last 10 characters of log group name
  # because it is random string suffix of log group name. So there is not risk of
  # name collision of delivery stream.
  name        = "CMXApp-${var.environment}-${random_string.upper_case_string[each.key].result}-cloudwatch_to_es"
  destination = "elasticsearch"


  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis_stream_to_push_cloudwatch_log_group_to_es[each.key].arn
    role_arn           = aws_iam_role.firehose_to_elastic_search_role.arn
  }

  s3_configuration {
    role_arn           = aws_iam_role.firehose_to_elastic_search_role.arn
    bucket_arn         = aws_s3_bucket.application_logs_bucket.arn
    buffer_size        = var.firehose_s3_backup_bucket_configuration_buffering_size
    buffer_interval    = var.firehose_s3_backup_bucket_configuration_buffering_interval
    compression_format = "GZIP"
    prefix             = var.firehose_s3_backup_bucket_configuration_prefix
    cloudwatch_logging_options {
      enabled         = var.firehose_s3_config_cloudwatch_logging_options_enabled
      log_group_name  = var.firehose_s3_config_cloudwatch_logging_options_log_group_name
      log_stream_name = var.firehose_s3_config_cloudwatch_logging_options_log_stream_name
    }
  }

  elasticsearch_configuration {
    domain_arn            = aws_elasticsearch_domain.application_elasticsearch_domain.arn
    role_arn              = aws_iam_role.firehose_to_elastic_search_role.arn
    index_name            = lower(each.value.index_name)
    s3_backup_mode        = var.firehose_elasticsearch_configuration_s3_backup_mode
    index_rotation_period = var.firehose_elasticsearch_configuration_index_rotation_period
    buffering_interval    = var.firehose_elasticsearch_configuration_buffering_interval
    buffering_size        = var.firehose_elasticsearch_configuration_buffering_size
    vpc_config {
      subnet_ids = [
        "${aws_subnet.private_subnet_1.id}",
      ]
      security_group_ids = ["${aws_security_group.application_firehose_stream_sg.id}"]
      role_arn           = aws_iam_role.firehose_to_elastic_search_role.arn
    }


    processing_configuration {
      enabled = var.firehose_record_lambda_func_processing_configuration_enabled

      processors {
        type = var.firehose_record_processors_type

        parameters {
          parameter_name  = var.firehose_processor_parameter_name
          parameter_value = "${aws_lambda_function.cloudwatch_log_groups_to_es.arn}:$LATEST"
        }

        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = var.firehose_elasticsearch_configuration_buffering_size
        }

        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = var.firehose_elasticsearch_configuration_buffering_interval
        }
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "cloudwatch_to_es"
      Name = "CodaMetrix Application Kinesis Delivery Stream - cloudwatch_to_es"
    }
  )
}
