data "aws_kms_key" "mu_job_manifest_key" {
  provider = aws.tools
  key_id   = var.job_manifest_kms_key_alias
}

data "aws_kms_key" "aws_s3_kms_key" {
  key_id = "alias/aws/s3"
}

# !!! Remove this and replace with our own sagemaker-data bucket
data "aws_kms_key" "sagemaker_data_key" {
  provider = aws.development
  key_id   = var.sagemaker_data_key_alias_arn
}

data "aws_iam_policy_document" "application_sqs_queue_kms_key_policy" {
  policy_id = "application_sqs_queue_kms_key_policy-${var.environment}"

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
    actions = ["kms:GenerateDataKey*", "kms:Encrypt", "kms:Decrypt"]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "application_cloudwatch_logs_kms_key_policy" {
  policy_id = "application_cloudwatch_logs_kms_key_policy-${var.environment}"

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

data "aws_iam_policy_document" "application_elasticsearch_kms_key_policy" {
  policy_id = "application_elasticsearch_kms_key_policy-${var.environment}"

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

# Encryption key for application RDS database
resource "aws_kms_key" "application_database_kms_key" {
  description             = "Key for encrypting the application database"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_database_kms_key"
      Name = "CodaMetrix Application KMS - application_database_kms_key"
    }
  )
}

resource "aws_kms_alias" "application_database_kms_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-application_database_key"
  target_key_id = aws_kms_key.application_database_kms_key.key_id
}

# Encryption key for application secrets
resource "aws_kms_key" "application_secrets_kms_key" {
  description             = "Key for encrypting the application secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_secrets_kms_key"
      Name = "CodaMetrix Application KMS - application_secrets_kms_key"
    }
  )
}

resource "aws_kms_alias" "application_secrets_kms_key_alias" {
  name          = var.application_secrets_kms_key_alias
  target_key_id = aws_kms_key.application_secrets_kms_key.key_id
}

# Encryption key for application logs bucket
resource "aws_kms_key" "application_logs_kms_key" {
  description             = "Key for encrypting application logs"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_logs_kms_key"
      Name = "CodaMetrix Application KMS - application_logs_kms_key"
    }
  )
}

resource "aws_kms_alias" "application_logs_kms_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-application_logs_key"
  target_key_id = aws_kms_key.application_logs_kms_key.key_id
}

# Encryption key for each health system
resource "aws_kms_key" "application_healthsystem_kms_key" {
  for_each                = toset(var.healthsystems)
  description             = "Key for encrypting data on behalf of health system '${each.value}'"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type         = "application_healthsystem_kms_key"
      Name         = "CodaMetrix Application KMS - application_healthsystem_kms_key"
      HealthSystem = each.value
    }
  )
}

resource "aws_kms_alias" "application_healthsystem_kms_key_alias" {
  for_each      = toset(var.healthsystems)
  name          = "alias/CodaMetrixApplication-${var.environment}-${each.value}-application_healthsystem_key"
  target_key_id = aws_kms_key.application_healthsystem_kms_key[each.value].key_id
}

# Encryption key for SNS topics
resource "aws_kms_key" "application_sns_topic_kms_key" {
  description             = "Key for encrypting data in SNS topics"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_sns_topic_kms_key"
      Name = "CodaMetrix Application KMS - application_sns_topic_kms_key"
    }
  )
}

resource "aws_kms_alias" "application_sns_topic_kms_key_alias" {
  name          = var.application_sns_topic_kms_key_alias
  target_key_id = aws_kms_key.application_sns_topic_kms_key.key_id
}

# Encryption key for SQS queues
resource "aws_kms_key" "application_sqs_queue_kms_key" {
  description             = "Key for encrypting data in SQS queues"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation
  policy                  = data.aws_iam_policy_document.application_sqs_queue_kms_key_policy.json

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_sqs_queue_kms_key"
      Name = "CodaMetrix Application KMS - application_sqs_queue_kms_key"
    }
  )
}

resource "aws_kms_alias" "application_sqs_queue_kms_key_alias" {
  name          = var.application_sqs_queue_kms_key_alias
  target_key_id = aws_kms_key.application_sqs_queue_kms_key.key_id
}

# Encryption key for application data warehouse
resource "aws_kms_key" "application_data_warehouse_kms_key" {
  description             = "Key for encrypting the application data warehouse"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_warehouse_kms_key"
      Name = "CodaMetrix Application KMS - application_data_warehouse_kms_key"
    }
  )
}

resource "aws_kms_alias" "application_data_warehouse_kms_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-application_data_warehouse_key"
  target_key_id = aws_kms_key.application_data_warehouse_kms_key.key_id
}

# Encryption key for process service data bucket
resource "aws_kms_key" "process_data_bucket_key" {
  description             = "Key for encrypting data in process service bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "process_data_bucket_key"
      Name = "CodaMetrix Application KMS - process_data_bucket_key"
    }
  )
}

resource "aws_kms_alias" "process_data_bucket_key_alias" {
  name          = var.process_data_bucket_key_alias
  target_key_id = aws_kms_key.process_data_bucket_key.key_id
}

# Encryption key for MU job data bucket
resource "aws_kms_key" "job_data_bucket_key" {
  description             = "Key for encrypting data in job data bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "job_data_bucket_key"
      Name = "CodaMetrix Application KMS - job_data_bucket_key"
    }
  )
}

resource "aws_kms_alias" "job_data_bucket_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-job_data_bucket_key"
  target_key_id = aws_kms_key.job_data_bucket_key.key_id
}

# Encryption key for Mu Sagemaker ephemeral storage
resource "aws_kms_key" "mu_sagemaker_ephemeral_storage_key" {
  description             = "Key for encrypting Mu Sagemaker ephemeral storage"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "mu_sagemaker_ephemeral_storage_key"
      Name = "CodaMetrix Application KMS - mu_sagemaker_ephemeral_storage_key"
    }
  )
}

resource "aws_kms_alias" "mu_sagemaker_ephemeral_storage_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-mu_sagemaker_ephemeral_storage_key"
  target_key_id = aws_kms_key.mu_sagemaker_ephemeral_storage_key.key_id
}

# Encryption key for application data lake
resource "aws_kms_key" "application_data_lake_emr_kms_key" {
  description             = "Key for emr encrypting the application data lake"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = {
    Usage       = "CodaMetrix Application"
    Type        = "application_data_lake_emr_kms_key"
    Name        = "CodaMetrix Application KMS - application_data_lake_emr_kms_key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "application_data_lake_emr_kms_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-application_data_lake_emr_kms_key"
  target_key_id = aws_kms_key.application_data_lake_emr_kms_key.key_id
}

# Encryption key for athena output
resource "aws_kms_key" "athena_output_kms_key" {
  description             = "Key for Athena encrypting the output data bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = {
    Usage       = "CodaMetrix Application"
    Type        = "athena_output_kms_key"
    Name        = "CodaMetrix Application KMS - athena_output_kms_key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "athena_output_kms_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-athena_output_kms_key"
  target_key_id = aws_kms_key.athena_output_kms_key.key_id
}

resource "aws_kms_grant" "application_data_warehouse_emr_grant" {
  name              = "CMXApp-${var.environment}-application_data_warehouse_emr_grant"
  key_id            = aws_kms_key.application_data_lake_emr_kms_key.key_id
  grantee_principal = aws_iam_role.application_emr_instance_role.arn
  operations        = ["Encrypt", "Decrypt", "ReEncryptFrom", "ReEncryptTo", "GenerateDataKey", "DescribeKey"]
}

# Encryption key for cloudwatch logs
resource "aws_kms_key" "application_cloudwatch_logs_kms_key" {
  description             = "Key for encrypting cloudwatch logs"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation
  policy                  = data.aws_iam_policy_document.application_cloudwatch_logs_kms_key_policy.json

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_cloudwatch_logs_kms_key"
      Name = "CodaMetrix Application KMS - application_cloudwatch_logs_kms_key"
    }
  )
}

resource "aws_kms_alias" "application_cloudwatch_logs_kms_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-application_cloudwatch_logs_key"
  target_key_id = aws_kms_key.application_cloudwatch_logs_kms_key.key_id
}

# Encryption key for Elasticsearch
resource "aws_kms_key" "application_elasticsearch_kms_key" {
  description             = "Key for encrypting Elasticsearch"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation
  policy                  = data.aws_iam_policy_document.application_elasticsearch_kms_key_policy.json

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_elasticsearch_kms_key"
      Name = "CodaMetrix Application KMS - application_elasticsearch_kms_key"
    }
  )
}

resource "aws_kms_alias" "application_elasticsearch_kms_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-application_elasticsearch_key"
  target_key_id = aws_kms_key.application_elasticsearch_kms_key.key_id
}

# Encryption key for Kinesis
resource "aws_kms_key" "application_kinesis_kms_key" {
  description             = "Key for encrypting application kinesis related stream and logs"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_kinesis_kms_key"
      Name = "CodaMetrix Application KMS - application_kinesis_kms_key"
    }
  )
}

resource "aws_kms_alias" "application_kinesis_kms_key_alias" {
  name          = "alias/CodaMetrixApplication-${var.environment}-application_kinesis_kms_key"
  target_key_id = aws_kms_key.application_kinesis_kms_key.key_id
}

output "application_database_kms_key_arn" {
  value = aws_kms_key.application_database_kms_key.arn
}

output "application_database_kms_key_id" {
  value = aws_kms_key.application_database_kms_key.key_id
}

output "application_database_kms_key_alias_arn" {
  value = aws_kms_alias.application_database_kms_key_alias.arn
}

output "application_secrets_kms_key_arn" {
  value = aws_kms_key.application_secrets_kms_key.arn
}

output "application_secrets_kms_key_id" {
  value = aws_kms_key.application_secrets_kms_key.key_id
}

output "application_secrets_kms_key_alias_arn" {
  value = aws_kms_alias.application_secrets_kms_key_alias.arn
}

output "application_sns_topic_kms_key_arn" {
  value = aws_kms_key.application_sns_topic_kms_key.arn
}

output "application_sns_topic_kms_key_id" {
  value = aws_kms_key.application_sns_topic_kms_key.key_id
}

output "application_sns_topic_kms_key_alias_arn" {
  value = aws_kms_alias.application_sns_topic_kms_key_alias.arn
}

output "application_sqs_queue_kms_key_arn" {
  value = aws_kms_key.application_sqs_queue_kms_key.arn
}

output "application_sqs_queue_kms_key_id" {
  value = aws_kms_key.application_sqs_queue_kms_key.key_id
}

output "application_sqs_queue_kms_key_alias_arn" {
  value = aws_kms_alias.application_sqs_queue_kms_key_alias.arn
}

output "application_data_warehouse_kms_key_arn" {
  value = aws_kms_key.application_data_warehouse_kms_key.arn
}

output "application_data_warehouse_kms_key_id" {
  value = aws_kms_key.application_data_warehouse_kms_key.key_id
}

output "application_data_warehouse_kms_key_alias_arn" {
  value = aws_kms_alias.application_data_warehouse_kms_key_alias.arn
}

output "application_cloudwatch_logs_kms_key_arn" {
  value = aws_kms_key.application_cloudwatch_logs_kms_key.arn
}

output "application_cloudwatch_logs_kms_key_id" {
  value = aws_kms_key.application_cloudwatch_logs_kms_key.key_id
}

output "application_cloudwatch_logs_kms_key_alias_arn" {
  value = aws_kms_alias.application_cloudwatch_logs_kms_key_alias.arn
}

output "application_elasticsearch_kms_key_arn" {
  value = aws_kms_key.application_elasticsearch_kms_key.arn
}

output "application_elasticsearch_kms_key_id" {
  value = aws_kms_key.application_elasticsearch_kms_key.key_id
}

output "application_elasticsearch_kms_key_alias_arn" {
  value = aws_kms_alias.application_elasticsearch_kms_key_alias.arn
}
