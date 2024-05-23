resource "aws_sqs_queue" "application_casebuilder_queue" {
  name                       = var.sqs_queues.casebuilder_queue.queue_name
  kms_master_key_id          = aws_kms_key.application_sqs_queue_kms_key.arn
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.application_casebuilder_deadletter_queue.arn}\",\"maxReceiveCount\":${var.sqs_queues.casebuilder_queue.max_receive_count}}"

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_casebuilder_queue"
      Name = "CodaMetrix Application SQS - application_casebuilder_queue"
    }
  )
}

# DLQ for casebuilde queue
resource "aws_sqs_queue" "application_casebuilder_deadletter_queue" {
  name                       = var.sqs_queues.casebuilder_queue.deadletter_queue_name
  kms_master_key_id          = aws_kms_key.application_sqs_queue_kms_key.arn

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_casebuilder_deadletter_queue"
      Name = "CodaMetrix Application SQS - application_casebuilder_deadletter_queue"
    }
  )
}

resource "aws_sqs_queue" "application_caseevents_queue" {
  name                       = var.sqs_queues.caseevents_queue.queue_name
  kms_master_key_id          = aws_kms_key.application_sqs_queue_kms_key.arn
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.application_caseevents_deadletter_queue.arn}\",\"maxReceiveCount\":${var.sqs_queues.caseevents_queue.max_receive_count}}"

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_caseevents_queue"
      Name = "CodaMetrix Application SQS - application_caseevents_queue"
    }
  )
}

# DLQ for caseevents queue
resource "aws_sqs_queue" "application_caseevents_deadletter_queue" {
  name                       = var.sqs_queues.caseevents_queue.deadletter_queue_name
  kms_master_key_id          = aws_kms_key.application_sqs_queue_kms_key.arn

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_caseevents_deadletter_queue"
      Name = "CodaMetrix Application SQS - application_caseevents_deadletter_queue"
    }
  )
}

resource "aws_sqs_queue" "application_activitylog_queue" {
  name              = var.sqs_queues.activitylog_queue.queue_name
  kms_master_key_id = aws_kms_key.application_sqs_queue_kms_key.arn

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_activitylog_queue"
      Name = "CodaMetrix Application SQS - application_activitylog_queue"
    }
  )
}

resource "aws_sqs_queue" "application_munotification_queue" {
  name              = var.sqs_queues.munotification_queue.queue_name
  kms_master_key_id = aws_kms_key.application_sqs_queue_kms_key.arn

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_munotification_queue"
      Name = "CodaMetrix Application SQS - application_munotification_queue"
    }
  )
}

resource "aws_sqs_queue" "application_externaltaskmonitor_queue" {
  name              = var.sqs_queues.externaltaskmonitor_queue.queue_name
  kms_master_key_id = aws_kms_key.application_sqs_queue_kms_key.arn

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_externaltaskmonitor_queue"
      Name = "CodaMetrix Application SQS - application_externaltaskmonitor_queue"
    }
  )
}

resource "aws_sqs_queue" "application_charge_processor_queue" {
  name                       = var.sqs_queues.charge_processor_queue.queue_name
  kms_master_key_id          = aws_kms_key.application_sqs_queue_kms_key.arn
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.application_charge_processor_deadletter_queue.arn}\",\"maxReceiveCount\":${var.sqs_queues.charge_processor_queue.max_receive_count}}"

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_charge_processor_queue"
      Name = "CodaMetrix Application SQS - application_charge_processor_queue"
    }
  )
}

# DLQ for charge processor queue
resource "aws_sqs_queue" "application_charge_processor_deadletter_queue" {
  name                       = var.sqs_queues.charge_processor_queue.deadletter_queue_name
  kms_master_key_id          = aws_kms_key.application_sqs_queue_kms_key.arn

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_charge_processor_deadletter_queue"
      Name = "CodaMetrix Application SQS - application_charge_processor_deadletter_queue"
    }
  )
}

output "application_casebuilder_queue_arn" {
  value = aws_sqs_queue.application_casebuilder_queue.arn
}

output "application_caseevents_queue_arn" {
  value = aws_sqs_queue.application_caseevents_queue.arn
}

output "application_activitylog_queue_arn" {
  value = aws_sqs_queue.application_activitylog_queue.arn
}

output "application_munotification_queue_arn" {
  value = aws_sqs_queue.application_munotification_queue.arn
}

output "application_externaltaskmonitor_queue_arn" {
  value = aws_sqs_queue.application_externaltaskmonitor_queue.arn
}

output "application_charge_processor_queue_arn" {
  value = aws_sqs_queue.application_charge_processor_queue.arn
}
