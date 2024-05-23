resource "aws_sqs_queue" "casebuilder_developer_queues" {
  for_each          = toset(keys(var.developers))
  name              = "${var.sqs_queue_prefix}-casebuilder-${each.value}"
  kms_master_key_id = aws_kms_key.developer_sqs_queue_kms_key[each.value].arn

  tags = {
    Usage         = "CodaMetrix Development"
    Name          = "${var.sqs_queue_prefix}-casebuilder-${each.value}"
    DeveloperName = each.value
  }
}

resource "aws_sqs_queue" "caseevents_developer_queues" {
  for_each          = toset(keys(var.developers))
  name              = "${var.sqs_queue_prefix}-caseevents-${each.value}"
  kms_master_key_id = aws_kms_key.developer_sqs_queue_kms_key[each.value].arn

  tags = {
    Usage         = "CodaMetrix Development"
    Name          = "${var.sqs_queue_prefix}-caseevents-${each.value}"
    DeveloperName = each.value
  }
}

resource "aws_sqs_queue" "activitylog_developer_queues" {
  for_each          = toset(keys(var.developers))
  name              = "${var.sqs_queue_prefix}-activitylog-${each.value}"
  kms_master_key_id = aws_kms_key.developer_sqs_queue_kms_key[each.value].arn

  tags = {
    Usage         = "CodaMetrix Development"
    Name          = "${var.sqs_queue_prefix}-activitylog-${each.value}"
    DeveloperName = each.value
  }
}

resource "aws_sqs_queue" "munotification_developer_queues" {
  for_each          = toset(keys(var.developers))
  name              = "${var.sqs_queue_prefix}-munotification-${each.value}"
  kms_master_key_id = aws_kms_key.developer_sqs_queue_kms_key[each.value].arn

  tags = {
    Usage         = "CodaMetrix Development"
    Name          = "${var.sqs_queue_prefix}-munotification-${each.value}"
    DeveloperName = each.value
  }
}

resource "aws_sqs_queue" "externaltaskmonitor_developer_queues" {
  for_each          = toset(keys(var.developers))
  name              = "${var.sqs_queue_prefix}-externaltaskmonitor-${each.value}"
  kms_master_key_id = aws_kms_key.developer_sqs_queue_kms_key[each.value].arn

  tags = {
    Usage         = "CodaMetrix Development"
    Name          = "${var.sqs_queue_prefix}-externaltaskmonitor-${each.value}"
    DeveloperName = each.value
  }
}

resource "aws_sqs_queue" "charge_processor_developer_queues" {
  for_each          = toset(keys(var.developers))
  name              = "${var.sqs_queue_prefix}-charge-processor-${each.value}"
  kms_master_key_id = aws_kms_key.developer_sqs_queue_kms_key[each.value].arn

  tags = {
    Usage         = "CodaMetrix Development"
    Name          = "${var.sqs_queue_prefix}-charge-processor-${each.value}"
    DeveloperName = each.value
  }
}

# SQS Queue Policy, enable case builder queue to be subscribed to the topic
resource "aws_sqs_queue_policy" "sns_topic_casebuilder_queue_access_policy" {
  for_each  = toset(keys(var.developers))
  queue_url = aws_sqs_queue.casebuilder_developer_queues[each.value].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Sid":"SendToCaseBuilderQueue",
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action": [
       "sqs:SetQueueAttributes",
       "sqs:SendMessage"
     ],
     "Resource": "${aws_sqs_queue.casebuilder_developer_queues[each.value].arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.developer_topics[each.value].arn}"
       }
     }
  }]
}
POLICY
}

# SQS Queue Policy, enable case event queue to be subscribed to the topic
resource "aws_sqs_queue_policy" "sns_topic_caseevents_queue_access_policy" {
  for_each  = toset(keys(var.developers))
  queue_url = aws_sqs_queue.caseevents_developer_queues[each.value].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Sid":"SendToCaseEventsQueue",
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action": [
       "sqs:SetQueueAttributes",
       "sqs:SendMessage"
     ],
     "Resource": "${aws_sqs_queue.caseevents_developer_queues[each.value].arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.developer_topics[each.value].arn}"
       }
     }
  }]
}
POLICY
}

# SQS Queue Policy, enable activity log queue to be subscribed to the topic
resource "aws_sqs_queue_policy" "sns_topic_activitylog_queue_access_policy" {
  for_each  = toset(keys(var.developers))
  queue_url = aws_sqs_queue.activitylog_developer_queues[each.value].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Sid":"SendToActivityLogQueue",
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action": [
       "sqs:SetQueueAttributes",
       "sqs:SendMessage"
     ],
     "Resource": "${aws_sqs_queue.activitylog_developer_queues[each.value].arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.developer_topics[each.value].arn}"
       }
     }
  }]
}
POLICY
}

# SQS Queue Policy, enable mu notification queue to be subscribed to the topic
resource "aws_sqs_queue_policy" "sns_topic_munotification_queue_access_policy" {
  for_each  = toset(keys(var.developers))
  queue_url = aws_sqs_queue.munotification_developer_queues[each.value].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Sid":"SendToMuNotificationQueue",
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action": [
       "sqs:SetQueueAttributes",
       "sqs:SendMessage"
     ],
     "Resource": "${aws_sqs_queue.munotification_developer_queues[each.value].arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn":  "${aws_sns_topic.developer_topics[each.value].arn}"
       }
     }
  }]
}
POLICY
}

# SQS Queue Policy, enable external task monitor queue to be subscribed to the topic
resource "aws_sqs_queue_policy" "sns_topic_externaltaskmonitor_queue_access_policy" {
  for_each  = toset(keys(var.developers))
  queue_url = aws_sqs_queue.externaltaskmonitor_developer_queues[each.value].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Sid":"SendToExternalTaskMonitorQueue",
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action": [
       "sqs:SetQueueAttributes",
       "sqs:SendMessage"
     ],
     "Resource": "${aws_sqs_queue.externaltaskmonitor_developer_queues[each.value].arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.developer_topics[each.value].arn}"
       }
     }
  }]
}
POLICY
}

# SQS Queue Policy, enable charge processor queue to be subscribed to the topic
resource "aws_sqs_queue_policy" "sns_topic_charge_processor_queue_access_policy" {
  for_each  = toset(keys(var.developers))
  queue_url = aws_sqs_queue.charge_processor_developer_queues[each.value].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Sid":"SendToChargeProcessorQueue",
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action": [
       "sqs:SetQueueAttributes",
       "sqs:SendMessage"
     ],
     "Resource": "${aws_sqs_queue.charge_processor_developer_queues[each.value].arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.developer_topics[each.value].arn}"
       }
     }
  }]
}
POLICY
}

output "casebuilder_queues" {
  value = aws_sqs_queue.casebuilder_developer_queues
}
output "caseevents_queues" {
  value = aws_sqs_queue.caseevents_developer_queues
}
output "activitylog_queues" {
  value = aws_sqs_queue.activitylog_developer_queues
}
output "munotification_queues" {
  value = aws_sqs_queue.munotification_developer_queues
}
output "externaltaskmonitor_queues" {
  value = aws_sqs_queue.externaltaskmonitor_developer_queues
}
output "charge_processor_queues" {
  value = aws_sqs_queue.charge_processor_developer_queues
}
