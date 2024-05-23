# CloudWath Alarms for low storage space for postgres databases
resource "aws_cloudwatch_metric_alarm" "database_free_storage_space_too_low_alarm" {
  for_each            = var.low_storage_space_cloudwatch_alarm.rds
  alarm_name          = "CMXDataCentral-${var.environment}-${each.value.name}-database_free_storage_space_too_low_alarm"
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
  alarm_actions       = [aws_sns_topic.environment_cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.environment_cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.ignore

  dimensions = {
    DBInstanceIdentifier  = each.value.db_identifier
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "${each.value.name}_free_storage_space_too_low_alarm"
      Name = "CodaMetrix Data Central CloudWatch Alarm - ${each.value.name}_free_storage_space_too_low_alarm"
    }
  )
}

# CloudWatch Alarm for Dundas server liveness. StatusCheckFailed > 0 for 5 minutes
resource "aws_cloudwatch_metric_alarm" "dundas_server_liveness_alarm" {
  alarm_name          = "CMXDataCentral-${var.environment}-dundas_server_liveness_alarm"
  comparison_operator = var.greater_than_comparison_operator
  metric_name         = "StatusCheckFailed"
  namespace           = var.cloudwatch_alarm_namespace.ec2
  period              = var.statistic_period
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Average"
  threshold           = var.dundas_server_liveness_threshold
  alarm_description   = "StatusCheckFailed > ${var.dundas_server_liveness_threshold} for 5 minutes"
  alarm_actions       = [aws_sns_topic.environment_cloudwatch_alarm_push_alerts_topic.arn]
  ok_actions          = [aws_sns_topic.environment_cloudwatch_alarm_push_alerts_topic.arn]
  treat_missing_data  = var.treat_missing_data.breaching

  dimensions = {
    AutoScalingGroupName  = aws_autoscaling_group.dundas_autoscaling_group.name
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_server_liveness_alarm"
      Name = "CodaMetrix Application CloudWatch Alarm - dundas_server_liveness_alarm"
    }
  )
}
