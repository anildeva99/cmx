resource "aws_sns_topic" "application_event_topic" {
  name              = var.sns_topics.event_topic.name
  display_name      = var.sns_topics.event_topic.display_name
  kms_master_key_id = aws_kms_key.application_sns_topic_kms_key.arn

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_event_topic"
      Name = "CodaMetrix Application SNS - application_event_topic"
    }
  )
}

# A topic for all CloudWatch alarms to push alerts to
resource "aws_sns_topic" "application_high_priority_alarm_topic" {
  name              = var.sns_topics.high_priority_alarm_topic.name
  display_name      = var.sns_topics.high_priority_alarm_topic.display_name

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_high_priority_alarm_topic"
      Name = "CodaMetrix Application SNS - application_high_priority_alarm_topic"
    }
  )
}

resource "aws_sns_topic" "application_medium_priority_alarm_topic" {
  name              = var.sns_topics.medium_priority_alarm_topic.name
  display_name      = var.sns_topics.medium_priority_alarm_topic.display_name

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_medium_priority_alarm_topic"
      Name = "CodaMetrix Application SNS - application_medium_priority_alarm_topic"
    }
  )
}

resource "aws_sns_topic" "application_low_priority_alarm_topic" {
  name              = var.sns_topics.low_priority_alarm_topic.name
  display_name      = var.sns_topics.low_priority_alarm_topic.display_name

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_low_priority_alarm_topic"
      Name = "CodaMetrix Application SNS - application_low_priority_alarm_topic"
    }
  )
}
