data "aws_kms_key" "aws_s3_kms_key" {
  key_id = "alias/aws/s3"
}

data "aws_iam_policy_document" "cloudwatch_logs_kms_key_policy" {
  policy_id = "cloudwatch_logs_kms_key_policy-${var.environment}"

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
    sid     = "CloudWatch encrypt permission"
    actions = ["kms:GenerateDataKey*", "kms:Encrypt*", "kms:Decrypt*", "kms:ReEncrypt*", "kms:Describe*"]
    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "elasticsearch_kms_key_policy" {
  policy_id = "elasticsearch_kms_key_policy-${var.environment}"

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
    sid     = "Elasticsearch encrypt permission"
    actions = ["kms:GenerateDataKey*", "kms:Encrypt", "kms:Decrypt"]
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    resources = ["*"]
  }

  statement {
    sid     = "Enable ES rotate indices role"
    actions = ["kms:GenerateDataKey*", "kms:Encrypt", "kms:Decrypt"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.elasticsearch_rotate_index_role.arn]
    }
    resources = ["*"]
  }
}

# Encryption key for secrets
resource "aws_kms_key" "secrets_kms_key" {
  description             = "Key for encrypting secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "secrets_kms_key"
      Name = "CodaMetrix Traffic Cop KMS - secrets_kms_key"
    }
  )
}

resource "aws_kms_alias" "secrets_kms_key_alias" {
  name          = var.secrets_kms_key_alias
  target_key_id = aws_kms_key.secrets_kms_key.key_id
}

# Encryption key for logs bucket
resource "aws_kms_key" "logs_kms_key" {
  description             = "Key for encrypting logs"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "logs_kms_key"
      Name = "CodaMetrix Traffic Cop KMS - logs_kms_key"
    }
  )
}

resource "aws_kms_alias" "logs_kms_key_alias" {
  name          = "alias/CMXTrafficCop-${var.environment}-logs_key"
  target_key_id = aws_kms_key.logs_kms_key.key_id
}

# Encryption key for cloudwatch logs
resource "aws_kms_key" "cloudwatch_logs_kms_key" {
  description             = "Key for encrypting cloudwatch logs"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation
  policy                  = data.aws_iam_policy_document.cloudwatch_logs_kms_key_policy.json

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "cloudwatch_logs_kms_key"
      Name = "CodaMetrix Traffic Cop KMS - cloudwatch_logs_kms_key"
    }
  )
}

resource "aws_kms_alias" "cloudwatch_logs_kms_key_alias" {
  name          = "alias/CMXTrafficCop-${var.environment}-cloudwatch_logs_key"
  target_key_id = aws_kms_key.cloudwatch_logs_kms_key.key_id
}

# Encryption key for Elasticsearch
resource "aws_kms_key" "elasticsearch_kms_key" {
  description             = "Key for encrypting Elasticsearch"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation
  policy                  = data.aws_iam_policy_document.elasticsearch_kms_key_policy.json

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "elasticsearch_kms_key"
      Name = "CodaMetrix Traffic Cop KMS - elasticsearch_kms_key"
    }
  )
}

resource "aws_kms_alias" "elasticsearch_kms_key_alias" {
  name          = "alias/CMXTrafficCop-${var.environment}-elasticsearch_key"
  target_key_id = aws_kms_key.elasticsearch_kms_key.key_id
}

# Encryption key for Kinesis
resource "aws_kms_key" "kinesis_kms_key" {
  description             = "Key for encrypting kinesis related stream and logs"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "kinesis_kms_key"
      Name = "CodaMetrix Traffic Cop KMS - kinesis_kms_key"
    }
  )
}

resource "aws_kms_alias" "kinesis_kms_key_alias" {
  name          = "alias/CMXTrafficCop-${var.environment}-kinesis_kms_key"
  target_key_id = aws_kms_key.kinesis_kms_key.key_id
}
