data "aws_iam_policy_document" "developer_sqs_queue_kms_key_policy" {
  policy_id = "developer_sqs_queue_kms_key_policy-${var.environment}"

  statement {
    sid     = "Enable IAM User Permissions"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  statement {
    sid     = "SNS encrypt permission"
    actions = ["kms:GenerateDataKey*", "kms:Encrypt", "kms:Decrypt" ]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    resources = ["*"]
  }
}

# Encryption key for SNS topics
resource "aws_kms_key" "developer_sns_topic_kms_key" {
  for_each                = toset(keys(var.developers))
  description             = "Key for encrypting data in ${each.value} SNS topic"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation

  tags = {
    Usage           = "CodaMetrix Development"
    Type            = "developer_sns_topic_kms_key"
    Name            = "CodaMetrix Developer KMS - developer_sns_topic_kms_key"
    DeveloperName   = each.value
    Environment     = var.environment
  }
}

resource "aws_kms_alias" "developer_sns_topic_kms_key_alias" {
  for_each                = toset(keys(var.developers))
  name                    = "alias/CodaMetrixDevelopment-${each.value}-developer_sns_topic_key"
  target_key_id           = aws_kms_key.developer_sns_topic_kms_key[each.value].key_id
}

# Encryption key for SQS queues
resource "aws_kms_key" "developer_sqs_queue_kms_key" {
  for_each                = toset(keys(var.developers))
  description             = "Key for encrypting data in ${each.value} SQS queues"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.developer_sqs_queue_kms_key_policy.json
  enable_key_rotation     = var.enable_key_rotation

  tags = {
    Usage           = "CodaMetrix Developer"
    Type            = "developer_sqs_queue_kms_key"
    Name            = "CodaMetrix Developer KMS - developer_sqs_queue_kms_key"
    DeveloperName   = each.value
    Environment     = var.environment
  }
}

resource "aws_kms_alias" "developer_sqs_queue_kms_key_alias" {
  for_each        = toset(keys(var.developers))
  name            = "alias/CodaMetrixDevelopment-${each.value}-developer_sqs_queue_key"
  target_key_id   = aws_kms_key.developer_sqs_queue_kms_key[each.value].key_id
}
