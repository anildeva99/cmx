# A topic for all CloudWatch alarms to push alerts to
resource "aws_sns_topic" "cloudwatch_alarm_push_alerts_topic" {
  name              = var.sns_topics.cloud_watch_alarm_topic.name
  display_name      = var.sns_topics.cloud_watch_alarm_topic.display_name

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "cloudwatch_alarm_push_alerts_topic"
      Name = "CodaMetrix Traffic Cop SNS - cloudwatch_alarm_push_alerts_topic"
    }
  )
}

resource "aws_sns_topic" "kibana_alarm_push_alerts_topic" {
  name              = var.sns_topics.kibana_alarm_topic.name
  display_name      = var.sns_topics.kibana_alarm_topic.display_name

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "kibana_alarm_push_alerts_topic"
      Name = "CodaMetrix Traffic Cop SNS - kibana_alarm_push_alerts_topic"
    }
  )
}
