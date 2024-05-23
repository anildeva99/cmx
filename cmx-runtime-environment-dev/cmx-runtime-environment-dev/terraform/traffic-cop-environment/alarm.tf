# CloudWatch Alarm for low storage space for Elastic Search
resource "aws_cloudwatch_metric_alarm" "elasticsearch_free_storage_space_too_low_alarm" {
  alarm_name          = "CMXTrafficCop-${var.environment}-elasticsearch_free_storage_space_too_low_alarm"
  comparison_operator = var.less_than_or_equal_to_comparison_operator
  metric_name         = var.free_storage_metrix_name
  namespace           = var.cloudwatch_alarm_namespace.elasticsearch
  period              = var.statistic_period
  datapoints_to_alarm = var.low_storage_space_cloudwatch_alarm.elasticsearch.elasticsearch.datapoints_to_alarm
  evaluation_periods  = var.low_storage_space_cloudwatch_alarm.elasticsearch.elasticsearch.evaluation_periods
  statistic           = var.low_storage_space_cloudwatch_alarm.elasticsearch.elasticsearch.statistic
  threshold           = var.low_storage_space_cloudwatch_alarm.elasticsearch.elasticsearch.free_storage_space_threshold
   alarm_description   = "Average elasticsearch free storage space over last 1 minutes is too low"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    DomainName = aws_elasticsearch_domain.elasticsearch_domain.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "elasticsearch_free_storage_space_too_low_alarm"
      Name = "CodaMetrix Traffic Cop CloudWatch - elasticsearch_free_storage_space_too_low_alarm"
    }
  )
}

# CloudWatch Alarms for low storage space for postgres databases
resource "aws_cloudwatch_metric_alarm" "database_free_storage_space_too_low_alarm" {
  for_each            = var.low_storage_space_cloudwatch_alarm.rds
  alarm_name          = "CMXTrafficCop-${var.environment}-${each.value.name}-database_free_storage_space_too_low_alarm"
  comparison_operator = var.less_than_or_equal_to_comparison_operator
  metric_name         = var.free_storage_metrix_name
  namespace           = var.cloudwatch_alarm_namespace.rds
  period              = var.statistic_period
  datapoints_to_alarm = each.value.datapoints_to_alarm
  evaluation_periods  = each.value.evaluation_periods
  statistic           = each.value.statistic
  threshold           = each.value.free_storage_space_threshold
  unit                = each.value.unit
  alarm_description   = "Average database free storage space over last 1 minutes is too low"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    DBInstanceIdentifier  = each.value.db_identifier
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "${each.value.name}_free_storage_space_too_low_alarm"
      Name = "CodaMetrix Traffic Cop CloudWatch - ${each.value.name}_free_storage_space_too_low_alarm"
    }
  )
}

# CloudWatch Alarm for Mirth liveness. StatusCheckFailed > 0 for 5 minutes
resource "aws_cloudwatch_metric_alarm" "mirth_liveness_alarm" {
  count               = var.mirth_alarms_enabled ? 1 : 0
  alarm_name          = "CMXTrafficCop-${var.environment}-mirth_liveness_alarm"
  comparison_operator = var.greater_than_comparison_operator
  metric_name         = "StatusCheckFailed"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.mirth_liveness_threshold
  alarm_description   = "StatusCheckFailed > ${var.mirth_liveness_threshold} for 5 minutes"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.mirth.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "mirth_liveness_alarm"
      Name = "CodaMetrix Traffic Cop CloudWatch Alarm - mirth_liveness_alarm"
    }
  )
}

# CloudWatch Alarm for Mirth network in. NetworkIn < X bytes for 5 minutes
resource "aws_cloudwatch_metric_alarm" "mirth_network_in_alarm" {
  count               = var.mirth_alarms_enabled ? 1 : 0
  alarm_name          = "CMXTrafficCop-${var.environment}-mirth_network_in_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "NetworkIn"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.mirth_network_throughput_threshold
  alarm_description   = "Average Network In throughput is < ${var.mirth_network_throughput_threshold} bytes for 5 minutes"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.mirth.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "mirth_network_in_alarm"
      Name = "CodaMetrix Traffic Cop CloudWatch Alarm - mirth_network_in_alarm"
    }
  )
}

# CloudWatch Alarm for Mirth network out. NetworkOut < X bytes for 5 minutes
resource "aws_cloudwatch_metric_alarm" "mirth_network_out_alarm" {
  count               = var.mirth_alarms_enabled ? 1 : 0
  alarm_name          = "CMXTrafficCop-${var.environment}-mirth_network_out_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "NetworkOut"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.mirth_network_throughput_threshold
  alarm_description   = "Average Network Out throughput is < ${var.mirth_network_throughput_threshold} bytes for 5 minutes"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.mirth.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "mirth_network_out_alarm"
      Name = "CodaMetrix Traffic Cop CloudWatch Alarm - mirth_network_out_alarm"
    }
  )
}

# CloudWatch Alarm for the Customer Router liveness. CPU < X% for 5 minutes
resource "aws_cloudwatch_metric_alarm" "customerrouter_1_liveness_alarm" {
  alarm_name          = "CMXTrafficCop-${var.environment}-customerrouter_1_liveness_alarm"
  comparison_operator = var.greater_than_comparison_operator
  metric_name         = "StatusCheckFailed"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.customerrouter_liveness_threshold
  alarm_description   = "StatusCheckFailed > ${var.customerrouter_liveness_threshold} for 5 minutes"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.customerrouter_1.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customerrouter_1_liveness_alarm"
      Name = "CodaMetrix Traffic Cop CloudWatch Alarm - customerrouter_1_liveness_alarm"
    }
  )
}

# CloudWatch Alarm for Customer Router 1 network in. NetworkIn < X bytes for 5 minutes
resource "aws_cloudwatch_metric_alarm" "customerrouter_1_network_in_alarm" {
  alarm_name          = "CMXTrafficCop-${var.environment}-customerrouter_1_network_in_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "NetworkIn"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.customerrouter_network_throughput_threshold
  alarm_description   = "Average Network In throughput is < ${var.customerrouter_network_throughput_threshold} bytes for 5 minutes"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.customerrouter_1.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customerrouter_1_network_in_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - customerrouter_1_network_in_alarm"
    }
  )
}

# CloudWatch Alarm for Customer Router 1 network out. NetworkOut < X bytes for 5 minutes
resource "aws_cloudwatch_metric_alarm" "customerrouter_1_network_out_alarm" {
  alarm_name          = "CMXApplication-${var.environment}-customerrouter_1_network_out_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "NetworkOut"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.customerrouter_network_throughput_threshold
  alarm_description   = "Average Network Out throughput is < ${var.customerrouter_network_throughput_threshold} bytes for 5 minutes"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    InstanceId  = aws_instance.customerrouter_1.id
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customerrouter_1_network_out_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - customerrouter_1_network_out_alarm"
    }
  )
}
