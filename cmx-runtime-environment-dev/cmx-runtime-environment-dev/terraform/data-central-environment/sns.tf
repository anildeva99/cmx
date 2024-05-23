# A topic for all CloudWatch alarms to push alerts to
resource "aws_sns_topic" "environment_cloudwatch_alarm_push_alerts_topic" {
  name              = var.sns_topics.cloud_watch_alarm_topic
  display_name      = var.cloud_watch_alarm_topic_display_name

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_cloudwatch_alarm_push_alerts_topic"
      Name = "CodaMetrix Data Central SNS - environment_cloudwatch_alarm_push_alerts_topic"
    }
  )
}
