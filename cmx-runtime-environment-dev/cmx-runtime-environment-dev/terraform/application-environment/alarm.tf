# CloudWath Alarm for low storage space for Elastic Search
resource "aws_cloudwatch_metric_alarm" "app_elasticsearch_free_storage_space_too_low_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-app_elasticsearch_free_storage_space_too_low_alarm"
  comparison_operator = var.less_than_or_equal_to_comparison_operator
  metric_name         = var.free_storage_metrix_name
  namespace           = var.cloudwatch_alarm_namespace.elastic_search
  period              = var.statistic_period
  datapoints_to_alarm = var.low_storage_space_cloudwatch_alarm.elastic_search.application_elasticsearch.datapoints_to_alarm
  evaluation_periods  = var.low_storage_space_cloudwatch_alarm.elastic_search.application_elasticsearch.evaluation_periods
  statistic           = var.low_storage_space_cloudwatch_alarm.elastic_search.application_elasticsearch.statistic
  threshold           = var.low_storage_space_cloudwatch_alarm.elastic_search.application_elasticsearch.free_storage_space_threshold
  alarm_description   = "Average elasticsearch free storage space over last 1 minutes is too low"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    DomainName = aws_elasticsearch_domain.application_elasticsearch_domain.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "app_elasticsearch_free_storage_space_too_low_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - app_elasticsearch_free_storage_space_too_low_alarm"
    }
  )
}

# CloudWath Alarms for low storage space for postgres databases
resource "aws_cloudwatch_metric_alarm" "database_free_storage_space_too_low_alarm" {
  for_each            = var.low_storage_space_cloudwatch_alarm.rds
  alarm_name          = "CMXApplication-${var.environment}-${each.value.name}-database_free_storage_space_too_low_alarm"
  comparison_operator = var.less_than_or_equal_to_comparison_operator
  metric_name         = var.free_storage_metrix_name
  namespace           = var.cloudwatch_alarm_namespace.rds
  period              = var.statistic_period
  datapoints_to_alarm = each.value.datapoints_to_alarm
  evaluation_periods  = each.value.evaluation_periods
  statistic           = each.value.statistic
  threshold           = each.value.free_storage_space_threshold
  unit                = each.value.unit
  alarm_description   = "Average ingress mirth database free storage space over last 1 minutes is too low"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    DBInstanceIdentifier  = each.value.db_identifier
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "${each.value.name}_free_storage_space_too_low_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - ${each.value.name}_free_storage_space_too_low_alarm"
    }
  )
}

# CloudWath Alarm for low storage space for Redshift db
resource "aws_cloudwatch_metric_alarm" "application_data_warehouse_free_storage_space_too_low_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_data_warehouse_free_storage_space_too_low_alarm"
  comparison_operator = var.greater_than_comparison_operator
  metric_name         = var.percentage_disk_space_used_metrix_name
  namespace           = var.cloudwatch_alarm_namespace.redshift
  period              = var.statistic_period
  evaluation_periods  = var.low_storage_space_cloudwatch_alarm.redshift.application_data_warehouse.evaluation_periods
  datapoints_to_alarm = var.low_storage_space_cloudwatch_alarm.redshift.application_data_warehouse.datapoints_to_alarm
  statistic           = var.low_storage_space_cloudwatch_alarm.redshift.application_data_warehouse.statistic
  threshold           = var.low_storage_space_cloudwatch_alarm.redshift.application_data_warehouse.percentage_disk_space_used_threshold
  alarm_description   = "Average Redshift cluster free storage space over last 1 minutes is too low"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    ClusterIdentifier  = aws_redshift_cluster.application_data_warehouse.cluster_identifier
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_warehouse_free_storage_space_too_low_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_data_warehouse_free_storage_space_too_low_alarm"
    }
  )
}

# CloudWatch Alarm for Ingress Mirth liveness. StatusCheckFailed > 0 for 5 minutes
resource "aws_cloudwatch_metric_alarm" "ingress_mirth_liveness_alarm" {
  count               = var.ingress_mirth_alarms_enabled ? 1 : 0
  alarm_name          = "CMXApplication-${var.environment}-ingress_mirth_liveness_alarm"
  comparison_operator = var.greater_than_comparison_operator
  metric_name         = "StatusCheckFailed"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.ingress_mirth_liveness_threshold
  alarm_description   = "StatusCheckFailed > ${var.ingress_mirth_liveness_threshold} for 5 minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.ingress_mirth.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_mirth_liveness_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - ingress_mirth_liveness_alarm"
    }
  )
}

# CloudWatch Alarm for Ingress Mirth network in. NetworkIn < X bytes for 5 minutes
resource "aws_cloudwatch_metric_alarm" "ingress_mirth_network_in_alarm" {
  count               = var.ingress_mirth_alarms_enabled ? 1 : 0
  alarm_name          = "CMXApplication-${var.environment}-ingress_mirth_network_in_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "NetworkIn"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.ingress_mirth_network_throughput_threshold
  alarm_description   = "Average Network In throughput is < ${var.ingress_mirth_network_throughput_threshold} bytes for 5 minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.ingress_mirth.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_mirth_network_in_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - ingress_mirth_network_in_alarm"
    }
  )
}

# CloudWatch Alarm for Ingress Mirth network out. NetworkOut < X bytes for 5 minutes
resource "aws_cloudwatch_metric_alarm" "ingress_mirth_network_out_alarm" {
  count               = var.ingress_mirth_alarms_enabled ? 1 : 0
  alarm_name          = "CMXApplication-${var.environment}-ingress_mirth_network_out_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "NetworkOut"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.ingress_mirth_network_throughput_threshold
  alarm_description   = "Average Network Out throughput is < ${var.ingress_mirth_network_throughput_threshold} bytes for 5 minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.ingress_mirth.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_mirth_network_out_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - ingress_mirth_network_out_alarm"
    }
  )
}

# CloudWatch Alarm for the Customer Networking CSR liveness. CPU < X% for 5 minutes
resource "aws_cloudwatch_metric_alarm" "customer_networking_csr_1_liveness_alarm" {
  count               = var.enable_customer_networking ? 1 : 0
  alarm_name          = "CMXApplication-${var.environment}-customer_networking_csr_1_liveness_alarm"
  comparison_operator = var.greater_than_comparison_operator
  metric_name         = "StatusCheckFailed"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.customer_networking_csr_1_liveness_threshold
  alarm_description   = "StatusCheckFailed > ${var.customer_networking_csr_1_liveness_threshold} for 5 minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.customer_networking_csr_1[0].id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customer_networking_csr_1_liveness_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - customer_networking_csr_1_liveness_alarm"
    }
  )
}

# CloudWatch Alarm for Customer Networking CSR 1 network in. NetworkIn < X bytes for 5 minutes
resource "aws_cloudwatch_metric_alarm" "customer_networking_csr_1_network_in_alarm" {
  count               = var.enable_customer_networking ? 1 : 0
  alarm_name          = "CMXApplication-${var.environment}-customer_networking_csr_1_network_in_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "NetworkIn"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.customer_networking_csr_1_network_throughput_threshold
  alarm_description   = "Average Network In throughput is < ${var.customer_networking_csr_1_network_throughput_threshold} bytes for 5 minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.customer_networking_csr_1[0].id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customer_networking_csr_1_network_in_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - customer_networking_csr_1_network_in_alarm"
    }
  )
}

# CloudWatch Alarm for Customer Networking CSR 1 network out. NetworkOut < X bytes for 5 minutes
resource "aws_cloudwatch_metric_alarm" "customer_networking_csr_1_network_out_alarm" {
  count               = var.enable_customer_networking ? 1 : 0
  alarm_name          = "CMXApplication-${var.environment}-customer_networking_csr_1_network_out_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "NetworkOut"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.customer_networking_csr_1_network_throughput_threshold
  alarm_description   = "Average Network Out throughput is < ${var.customer_networking_csr_1_network_throughput_threshold} bytes for 5 minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.customer_networking_csr_1[0].id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customer_networking_csr_1_network_out_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - customer_networking_csr_1_network_out_alarm"
    }
  )
}

# CloudWatch Alarm for EMR liveness. CoreNodesRunning < 1 for 5 minutes
resource "aws_cloudwatch_metric_alarm" "application_emr_core_nodes_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_emr_core_nodes_alarm"
  comparison_operator = "LessThanThreshold"
  metric_name         = "CoreNodesRunning"
  namespace           = var.cloudwatch_alarm_namespace.emr
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "EMR core nodes count < 1 for 5 minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    JobFlowId  = aws_emr_cluster.application_data_warehouse_emr_spark_cluster.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_emr_core_nodes_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_emr_core_nodes_alarm"
    }
  )
}

# CloudWatch Alarm for EMR disk space. HDFSUtilization > 75 for 5 minutes
resource "aws_cloudwatch_metric_alarm" "application_emr_hdfs_utilization_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_emr_hdfs_utilization_alarm"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "HDFSUtilization"
  namespace           = var.cloudwatch_alarm_namespace.emr
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "EMR HDFS utilization > 75 for 5 minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    JobFlowId  = aws_emr_cluster.application_data_warehouse_emr_spark_cluster.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_emr_hdfs_utilization_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_emr_hdfs_utilization_alarm"
    }
  )
}

# CloudWatch Alarm for Activity Log SQS Queue. ApproximateNumberOfMessagesVisible > X for Y minutes
resource "aws_cloudwatch_metric_alarm" "application_activitylog_queue_size_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_activitylog_queue_size_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = var.cloudwatch_alarm_namespace.sqs
  period              = 60
  evaluation_periods  = var.activitylog_queue_alarm_minutes
  datapoints_to_alarm = var.activitylog_queue_alarm_minutes
  statistic           = "Average"
  threshold           = var.activitylog_queue_alarm_count_threshold
  alarm_description   = "Activity Log queue > ${var.activitylog_queue_alarm_count_threshold} visible messages for ${var.activitylog_queue_alarm_minutes} minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    QueueName  = aws_sqs_queue.application_activitylog_queue.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_activitylog_queue_size_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_activitylog_queue_size_alarm"
    }
  )
}

# CloudWatch Alarm for Case Builder SQS Queue. ApproximateNumberOfMessagesVisible > X for Y minutes
resource "aws_cloudwatch_metric_alarm" "application_casebuilder_queue_size_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_casebuilder_queue_size_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = var.cloudwatch_alarm_namespace.sqs
  period              = 60
  evaluation_periods  = var.casebuilder_queue_alarm_minutes
  datapoints_to_alarm = var.casebuilder_queue_alarm_minutes
  statistic           = "Average"
  threshold           = var.casebuilder_queue_alarm_count_threshold
  alarm_description   = "Activity Log queue > ${var.casebuilder_queue_alarm_count_threshold} visible messages for ${var.casebuilder_queue_alarm_minutes} minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    QueueName  = aws_sqs_queue.application_casebuilder_queue.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_casebuilder_queue_size_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_casebuilder_queue_size_alarm"
    }
  )
}

# CloudWatch Alarm for Case Builder Deadletter SQS Queue. ApproximateNumberOfMessagesVisible > X for Y minutes
resource "aws_cloudwatch_metric_alarm" "application_casebuilder_deadletter_queue_size_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_casebuilder_deadletter_queue_size_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = var.cloudwatch_alarm_namespace.sqs
  period              = 60
  evaluation_periods  = var.casebuilder_deadletter_queue_alarm_minutes
  datapoints_to_alarm = var.casebuilder_deadletter_queue_alarm_minutes
  statistic           = "Average"
  threshold           = var.casebuilder_deadletter_queue_alarm_count_threshold
  alarm_description   = "Activity Log queue > ${var.casebuilder_deadletter_queue_alarm_count_threshold} visible messages for ${var.casebuilder_deadletter_queue_alarm_minutes} minutes"
  alarm_actions       = [aws_sns_topic.application_medium_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_medium_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    QueueName  = aws_sqs_queue.application_casebuilder_deadletter_queue.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_casebuilder_deadletter_queue_size_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_casebuilder_deadletter_queue_size_alarm"
    }
  )
}

# CloudWatch Alarm for Case Events SQS Queue. ApproximateNumberOfMessagesVisible > X for Y minutes
resource "aws_cloudwatch_metric_alarm" "application_caseevents_queue_size_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_caseevents_queue_size_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = var.cloudwatch_alarm_namespace.sqs
  period              = 60
  evaluation_periods  = var.caseevents_queue_alarm_minutes
  datapoints_to_alarm = var.caseevents_queue_alarm_minutes
  statistic           = "Average"
  threshold           = var.caseevents_queue_alarm_count_threshold
  alarm_description   = "Activity Log queue > ${var.caseevents_queue_alarm_count_threshold} visible messages for ${var.caseevents_queue_alarm_minutes} minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    QueueName  = aws_sqs_queue.application_caseevents_queue.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_caseevents_queue_size_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_caseevents_queue_size_alarm"
    }
  )
}

# CloudWatch Alarm for Case Events Deadletter SQS Queue. ApproximateNumberOfMessagesVisible > X for Y minutes
resource "aws_cloudwatch_metric_alarm" "application_caseevents_deadletter_queue_size_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_caseevents_deadletter_queue_size_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = var.cloudwatch_alarm_namespace.sqs
  period              = 60
  evaluation_periods  = var.caseevents_deadletter_queue_alarm_minutes
  datapoints_to_alarm = var.caseevents_deadletter_queue_alarm_minutes
  statistic           = "Average"
  threshold           = var.caseevents_deadletter_queue_alarm_count_threshold
  alarm_description   = "Activity Log queue > ${var.caseevents_deadletter_queue_alarm_count_threshold} visible messages for ${var.caseevents_deadletter_queue_alarm_minutes} minutes"
  alarm_actions       = [aws_sns_topic.application_medium_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_medium_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    QueueName  = aws_sqs_queue.application_caseevents_deadletter_queue.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_caseevents_deadletter_queue_size_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_caseevents_deadletter_queue_size_alarm"
    }
  )
}

# CloudWatch Alarm for Mu Notification SQS Queue. ApproximateNumberOfMessagesVisible > X for Y minutes
resource "aws_cloudwatch_metric_alarm" "application_munotification_queue_size_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_munotification_queue_size_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = var.cloudwatch_alarm_namespace.sqs
  period              = 60
  evaluation_periods  = var.munotification_queue_alarm_minutes
  datapoints_to_alarm = var.munotification_queue_alarm_minutes
  statistic           = "Average"
  threshold           = var.munotification_queue_alarm_count_threshold
  alarm_description   = "Activity Log queue > ${var.munotification_queue_alarm_count_threshold} visible messages for ${var.munotification_queue_alarm_minutes} minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    QueueName  = aws_sqs_queue.application_munotification_queue.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_munotification_queue_size_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_munotification_queue_size_alarm"
    }
  )
}

# CloudWatch Alarm for External Task Monitor SQS Queue. ApproximateNumberOfMessagesVisible > X for Y minutes
resource "aws_cloudwatch_metric_alarm" "application_externaltaskmonitor_queue_size_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_externaltaskmonitor_queue_size_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = var.cloudwatch_alarm_namespace.sqs
  period              = 60
  evaluation_periods  = var.externaltaskmonitor_queue_alarm_minutes
  datapoints_to_alarm = var.externaltaskmonitor_queue_alarm_minutes
  statistic           = "Average"
  threshold           = var.externaltaskmonitor_queue_alarm_count_threshold
  alarm_description   = "Activity Log queue > ${var.externaltaskmonitor_queue_alarm_count_threshold} visible messages for ${var.externaltaskmonitor_queue_alarm_minutes} minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    QueueName  = aws_sqs_queue.application_externaltaskmonitor_queue.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_externaltaskmonitor_queue_size_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_externaltaskmonitor_queue_size_alarm"
    }
  )
}

# CloudWatch Alarm for Charge Processor SQS Queue. ApproximateNumberOfMessagesVisible > X for Y minutes
resource "aws_cloudwatch_metric_alarm" "application_charge_processor_queue_size_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_charge_processor_queue_size_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = var.cloudwatch_alarm_namespace.sqs
  period              = 60
  evaluation_periods  = var.charge_processor_queue_alarm_minutes
  datapoints_to_alarm = var.charge_processor_queue_alarm_minutes
  statistic           = "Average"
  threshold           = var.charge_processor_queue_alarm_count_threshold
  alarm_description   = "Activity Log queue > ${var.charge_processor_queue_alarm_count_threshold} visible messages for ${var.charge_processor_queue_alarm_minutes} minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    QueueName  = aws_sqs_queue.application_charge_processor_queue.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_charge_processor_queue_size_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_charge_processor_queue_size_alarm"
    }
  )
}

# CloudWatch Alarm for Charge Processor Deadletter SQS Queue. ApproximateNumberOfMessagesVisible > X for Y minutes
resource "aws_cloudwatch_metric_alarm" "application_charge_processor_deadletter_queue_size_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-application_charge_processor_deadletter_queue_size_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = var.cloudwatch_alarm_namespace.sqs
  period              = 60
  evaluation_periods  = var.charge_processor_deadletter_queue_alarm_minutes
  datapoints_to_alarm = var.charge_processor_deadletter_queue_alarm_minutes
  statistic           = "Average"
  threshold           = var.charge_processor_deadletter_queue_alarm_count_threshold
  alarm_description   = "Activity Log queue > ${var.charge_processor_deadletter_queue_alarm_count_threshold} visible messages for ${var.charge_processor_deadletter_queue_alarm_minutes} minutes"
  alarm_actions       = [aws_sns_topic.application_medium_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_medium_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    QueueName  = aws_sqs_queue.application_charge_processor_deadletter_queue.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_charge_processor_deadletter_queue_size_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - application_charge_processor_deadletter_queue_size_alarm"
    }
  )
}

# CloudWatch Alarm for Data Warehouse MSK broker root disk usage. RootDiskUsed > X% for 10 minutes
resource "aws_cloudwatch_metric_alarm" "application_datawarehouse_msk_broker_disk_usage_alarm" {
  count               = var.number_of_kafka_broker_nodes
  alarm_name          = "CMXApplication-${var.environment}-application_datawarehouse_msk_broker_${count.index + 1}_disk_usage_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "RootDiskUsed"
  namespace           = var.cloudwatch_alarm_namespace.msk
  period              = var.statistic_period
  evaluation_periods  = 10
  datapoints_to_alarm = 10
  statistic           = "Average"
  threshold           = var.datawarehouse_msk_broker_disk_use_threshold
  alarm_description   = "MSK Broker ${count.index + 1} root disk usage > ${var.datawarehouse_msk_broker_disk_use_threshold}% for 10 minutes"
  alarm_actions       = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  ok_actions          = [aws_sns_topic.application_high_priority_alarm_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    "Cluster Name"  = aws_msk_cluster.application_data_warehouse_msk_cluster.cluster_name
    "Broker ID"     = count.index + 1
  }

  tags = merge(
    var.shared_resource_tags,
    {
      BrokerID = count.index + 1
      Type     = "application_datawarehouse_msk_broker_disk_usage_alarm"
      Name     = "CodaMetrix Application CloudWatch Alarm - application_datawarehouse_msk_broker_disk_usage_alarm"
    }
  )
}
