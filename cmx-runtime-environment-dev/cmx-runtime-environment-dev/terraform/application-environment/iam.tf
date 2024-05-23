######################
# AWS Managed Policies
######################
data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "AmazonEKSServicePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "AmazonRDSEnhancedMonitoringRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy" "AmazonESCognitoPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
}

data "aws_iam_policy" "AmazonSageMakerFullAccessPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

data "aws_iam_policy" "AmazonAthenaFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

data "template_file" "application_data_lake_athena_user_name" {
  count    = length(var.data_lake_additional_users)
  template = "$${user_name}-AthenaDataLake-$${env}"
  vars = {
    user_name = "${element(var.data_lake_additional_users, count.index)}"
    env       = var.environment
  }
}

locals {
  json_list_item = <<STRING
"%s"
STRING

  s3_bucket_contents_list_item = <<STRING
"%s/*"
STRING

  iam_dr_kms_arn_prefix = "arn:aws:kms:${var.dr_region}:${data.aws_caller_identity.current.account_id}:"
}

######################
# Assume Role policies
######################
data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

#################################################################
# Assume Role policy, enable login account root assume roles that
# this policy is attached to. Requires MFA to assume the role.
#################################################################
data "aws_iam_policy_document" "sso_assume_role_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.sso_login_account_id}:root"]
    }

    condition {
      test     = "Null"
      variable = "aws:MultiFactorAuthAge"

      values = [
        "false"
      ]
    }
  }
}
######################
# Developers Policies
######################
resource "aws_iam_policy" "application_developers_s3_access_policy" {
  name        = "CodaMetrixApplication-${var.environment}-developers_s3_access_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to platform S3 buckets for developers"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        ${join(", ", formatlist(local.json_list_item, values(aws_s3_bucket.application_healthsystem_ingest_bucket).*.arn))},
        ${join(", ", formatlist(local.s3_bucket_contents_list_item, values(aws_s3_bucket.application_healthsystem_ingest_bucket).*.arn))},
        ${join(", ", formatlist(local.json_list_item, values(aws_s3_bucket.application_tenant_documents_bucket).*.arn))},
        ${join(", ", formatlist(local.s3_bucket_contents_list_item, values(aws_s3_bucket.application_tenant_documents_bucket).*.arn))},
        "${aws_s3_bucket.job_data_bucket.arn}",
        "${aws_s3_bucket.job_data_bucket.arn}/*",
        "${aws_s3_bucket.process_data_bucket.arn}",
        "${aws_s3_bucket.process_data_bucket.arn}/*",
        "${aws_s3_bucket.process_data_bucket.arn}",
        "${aws_s3_bucket.process_data_bucket.arn}/*",
        "${aws_s3_bucket.application_data_lake_bucket.arn}",
        "${aws_s3_bucket.application_data_lake_bucket.arn}/*",
        "arn:aws:s3:::${var.sagemaker_data_bucket}",
        "arn:aws:s3:::${var.sagemaker_data_bucket}/*"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt",
        "kms:Encrypt"
      ],
      "Effect": "Allow",
      "Resource": [
        ${join(", ", formatlist(local.json_list_item, values(aws_kms_key.application_healthsystem_kms_key).*.arn))},
        ${join(", ", formatlist(local.json_list_item, values(aws_kms_key.application_healthsystem_kms_key).*.arn))},
        "${aws_kms_alias.job_data_bucket_key_alias.target_key_arn}",
        "${aws_kms_alias.process_data_bucket_key_alias.target_key_arn}",
        "${aws_kms_alias.application_data_lake_emr_kms_key_alias.target_key_arn}",
        "${data.aws_kms_key.sagemaker_data_key.arn}"
      ],
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_developers_sqs_access_policy" {
  name        = "CodaMetrixApplication-${var.environment}-developers_sqs_access_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to additional platform SQS queues for developers"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:ChangeMessageVisibilityBatch",
        "sqs:DeleteMessage",
        "sqs:DeleteMessageBatch",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListQueueTags",
        "sqs:ListQueues",
        "sqs:PurgeQueue",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:SendMessageBatch",
        "sqs:SetQueueAttributes",
        "sqs:TagQueue",
        "sqs:UntagQueue"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sqs_queue.application_casebuilder_queue.arn}",
        "${aws_sqs_queue.application_casebuilder_deadletter_queue.arn}",
        "${aws_sqs_queue.application_charge_processor_queue.arn}",
        "${aws_sqs_queue.application_charge_processor_deadletter_queue.arn}",
        "${aws_sqs_queue.application_activitylog_queue.arn}",
        "${aws_sqs_queue.application_caseevents_deadletter_queue.arn}"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_sqs_queue_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "sqs.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_developers_misc_access_policy" {
  name        = "CodaMetrixApplication-${var.environment}-developers_misc_access_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to additional platform resources for developers"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:ConfirmSubscription",
        "sns:GetEndpointAttributes",
        "sns:GetSubscriptionAttributes",
        "sns:GetTopicAttributes",
        "sns:ListSubscriptions",
        "sns:ListTopics",
        "sns:Publish",
        "sns:SetSubscriptionAttributes",
        "sns:Subscribe",
        "sns:Unsubscribe"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sns_topic.application_event_topic.arn}"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_sns_topic_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "sns.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    },
    {
      "Action": [
        "eks:ListClusters"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "${aws_eks_cluster.application_cluster.arn}"
    },
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_alias.mu_sagemaker_ephemeral_storage_key_alias.target_key_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetAccountPublicAccessBlock",
        "s3:ListAllMyBuckets",
        "s3:HeadBucket",
        "sqs:ListQueues",
        "sns:ListTopics"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_eks_access_policy" {
  name        = "CodaMetrixApplication-${var.environment}-eks_access_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to EKS (kubernetes) resources"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:ListClusters"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "${aws_eks_cluster.application_cluster.arn}"
    }
  ]
}
POLICY
}

######################
# Application policies
######################
resource "aws_iam_policy" "application_secrets_kms_key_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-secrets_kms_key_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to the key used for encrypting secrets, via the secrets manager"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_secrets_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "secretsmanager.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_secrets_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-secrets_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to application Redis and Security secrets"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecrets",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_secretsmanager_secret.application_redis_secret.arn}",
        "${aws_secretsmanager_secret.application_security_secret.arn}",
        "${aws_secretsmanager_secret.application_smtp_secret.arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "new_relic_secrets_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-new_relic_secrets_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to New Relic secret"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecrets",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_secretsmanager_secret.new_relic_license_key_secret.arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_elasticsearch_usage_policy" {
  name        = "CMXApp-${var.environment}-application_elasticsearch_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to all application elasticsearch HTTP methods"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["es:ESHttp*"],
      "Resource": "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_database_secrets_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-database_secrets_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to all application database secrets"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecrets",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Effect": "Allow",
      "Resource": [
        ${join(", ", formatlist(local.json_list_item, values(aws_secretsmanager_secret.application_database_secret).*.arn))}
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_oauth_process_secrets_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-oauth_process_secrets_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to the Process Service Oauth secrets"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecrets",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_secretsmanager_secret.application_oauth_process_secret.arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_oauth_monitor_secrets_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-oauth_monitor_secrets_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to the Monitor Service Oauth secrets"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecrets",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_secretsmanager_secret.application_oauth_monitor_secret.arn}"
      ]
    }
  ]
}
POLICY
}

# Mu Sagemaker ephemeral storage encryption key access
resource "aws_iam_policy" "mu_sagemaker_ephemeral_storage_key_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-mu_sagemaker_ephemeral_storage_key_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to the key used for encrypting Mu Sagemaker ephemeral storage, via ???"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_alias.mu_sagemaker_ephemeral_storage_key_alias.target_key_arn}"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_healthsystem_ingest_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-healthsystem_ingest_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to all healthsystem-level ingest buckets"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        ${join(", ", formatlist(local.json_list_item, values(aws_s3_bucket.application_healthsystem_ingest_bucket).*.arn))},
        ${join(", ", formatlist(local.s3_bucket_contents_list_item, values(aws_s3_bucket.application_healthsystem_ingest_bucket).*.arn))}
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": [ ${join(", ", formatlist(local.json_list_item, values(aws_kms_key.application_healthsystem_kms_key).*.arn))} ],
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_tenant_documents_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-tenant_documents_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to all tenant-level document buckets"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        ${join(", ", formatlist(local.json_list_item, values(aws_s3_bucket.application_tenant_documents_bucket).*.arn))},
        ${join(", ", formatlist(local.s3_bucket_contents_list_item, values(aws_s3_bucket.application_tenant_documents_bucket).*.arn))}
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": [ ${join(", ", formatlist(local.json_list_item, values(aws_kms_key.application_healthsystem_kms_key).*.arn))} ],
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_tenant_documents_bucket_read_only_policy" {
  name        = "CodaMetrixApplication-${var.environment}-tenant_documents_bucket_read_only_policy"
  path        = var.iam_resource_path
  description = "This policy gives read access to all tenant-level document buckets"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        ${join(", ", formatlist(local.json_list_item, values(aws_s3_bucket.application_tenant_documents_bucket).*.arn))},
        ${join(", ", formatlist(local.s3_bucket_contents_list_item, values(aws_s3_bucket.application_tenant_documents_bucket).*.arn))}
      ]
    },
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": [ ${join(", ", formatlist(local.json_list_item, values(aws_kms_key.application_healthsystem_kms_key).*.arn))} ],
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}


# Process Service Bucket Policy
resource "aws_iam_policy" "processservice_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-processservice_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the process service bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.process_data_bucket.arn}",
        "${aws_s3_bucket.process_data_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_alias.process_data_bucket_key_alias.target_key_arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

# Mu Job Data Bucket Policy
resource "aws_iam_policy" "job_data_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-job_data_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the Mu job data bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.job_data_bucket.arn}",
        "${aws_s3_bucket.job_data_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_alias.job_data_bucket_key_alias.target_key_arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

# Mu Job Manifest Bucket Policy
resource "aws_iam_policy" "job_manifest_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-job_manifest_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read access to the Mu job manifest bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.job_manifest_bucket}",
        "arn:aws:s3:::${var.job_manifest_bucket}/*"
      ]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${data.aws_kms_key.mu_job_manifest_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

# Sagemaker Data Bucket Policy
# !!! Remove this and replace with our own sagemaker-data bucket
resource "aws_iam_policy" "sagemaker_data_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-sagemaker_data_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read access to the Mu sagemaker data bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.sagemaker_data_bucket}",
        "arn:aws:s3:::${var.sagemaker_data_bucket}/*"
      ]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "${data.aws_kms_key.sagemaker_data_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

# Data Lake Bucket Policy
resource "aws_iam_policy" "application_data_lake_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-data_lake_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the data lake bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.application_data_lake_bucket.arn}",
        "${aws_s3_bucket.application_data_lake_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_alias.application_data_lake_emr_kms_key_alias.target_key_arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

# Data Lake Bucket Read-Only Policy
resource "aws_iam_policy" "application_data_lake_bucket_readonly_policy" {
  name        = "CodaMetrixApplication-${var.environment}-data_lake_bucket_readonly_policy"
  path        = var.iam_resource_path
  description = "This policy gives read-only access to the data lake bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.application_data_lake_bucket.arn}",
        "${aws_s3_bucket.application_data_lake_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_alias.application_data_lake_emr_kms_key_alias.target_key_arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

# Data Lake Athena Output Bucket Policy
resource "aws_iam_policy" "application_data_lake_athena_output_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-data_lake_athena_output_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the data lake Athena output bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.application_data_lake_athena_output_bucket.arn}",
        "${aws_s3_bucket.application_data_lake_athena_output_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_alias.athena_output_kms_key_alias.target_key_arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "s3.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

# Configuration Bucket Policy
resource "aws_iam_policy" "application_configuration_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-configuration_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the configuration bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.application_configuration_bucket.arn}",
        "${aws_s3_bucket.application_configuration_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_logs_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-logs_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the application logs bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.application_logs_bucket.arn}",
        "${aws_s3_bucket.application_logs_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

# Ingress Mirth Temp Bucket Policy
resource "aws_iam_policy" "mirth_temp_bucket_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-mirth_temp_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the mirth temp bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.mirth_temp_bucket.arn}",
        "${aws_s3_bucket.mirth_temp_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_event_topic_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-event_topic_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the 'event' SNS topic"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:ConfirmSubscription",
        "sns:GetEndpointAttributes",
        "sns:GetSubscriptionAttributes",
        "sns:GetTopicAttributes",
        "sns:ListSubscriptions",
        "sns:ListTopics",
        "sns:Publish",
        "sns:SetSubscriptionAttributes",
        "sns:Subscribe",
        "sns:Unsubscribe"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sns_topic.application_event_topic.arn}"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_sns_topic_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "sns.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_create_topic_policy" {
  name        = "CodaMetrixApplication-${var.environment}-create_topic_policy"
  path        = var.iam_resource_path
  description = "This policy gives the ability to create new SNS topics"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:CreateTopic"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_create_queue_policy" {
  name        = "CodaMetrixApplication-${var.environment}-create_queue_policy"
  path        = var.iam_resource_path
  description = "This policy gives the ability to create new SQS queues"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:CreateQueue"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_casebuilder_queue_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-casebuilder_queue_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the 'casebuilder' SQS queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:ChangeMessageVisibilityBatch",
        "sqs:DeleteMessage",
        "sqs:DeleteMessageBatch",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListQueueTags",
        "sqs:ListQueues",
        "sqs:PurgeQueue",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:SendMessageBatch",
        "sqs:SetQueueAttributes",
        "sqs:TagQueue",
        "sqs:UntagQueue"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sqs_queue.application_casebuilder_queue.arn}",
        "${aws_sqs_queue.application_casebuilder_deadletter_queue.arn}"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_sqs_queue_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "sqs.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_caseevents_queue_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-caseevents_queue_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the 'caseevents' SQS queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:ChangeMessageVisibilityBatch",
        "sqs:DeleteMessage",
        "sqs:DeleteMessageBatch",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListQueueTags",
        "sqs:ListQueues",
        "sqs:PurgeQueue",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:SendMessageBatch",
        "sqs:SetQueueAttributes",
        "sqs:TagQueue",
        "sqs:UntagQueue"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sqs_queue.application_caseevents_queue.arn}",
        "${aws_sqs_queue.application_caseevents_deadletter_queue.arn}"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_sqs_queue_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "sqs.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_activitylog_queue_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-activitylog_queue_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the 'activitylog' SQS queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:ChangeMessageVisibilityBatch",
        "sqs:DeleteMessage",
        "sqs:DeleteMessageBatch",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListQueueTags",
        "sqs:ListQueues",
        "sqs:PurgeQueue",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:SendMessageBatch",
        "sqs:SetQueueAttributes",
        "sqs:TagQueue",
        "sqs:UntagQueue"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sqs_queue.application_activitylog_queue.arn}"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_sqs_queue_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "sqs.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_munotification_queue_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-munotification_queue_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the 'munotification' SQS queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:ChangeMessageVisibilityBatch",
        "sqs:DeleteMessage",
        "sqs:DeleteMessageBatch",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListQueueTags",
        "sqs:ListQueues",
        "sqs:PurgeQueue",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:SendMessageBatch",
        "sqs:SetQueueAttributes",
        "sqs:TagQueue",
        "sqs:UntagQueue"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sqs_queue.application_munotification_queue.arn}"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_sqs_queue_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "sqs.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_externaltaskmonitor_queue_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-externaltaskmonitor_queue_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the 'externaltaskmonitor' SQS queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:ChangeMessageVisibilityBatch",
        "sqs:DeleteMessage",
        "sqs:DeleteMessageBatch",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListQueueTags",
        "sqs:ListQueues",
        "sqs:PurgeQueue",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:SendMessageBatch",
        "sqs:SetQueueAttributes",
        "sqs:TagQueue",
        "sqs:UntagQueue"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sqs_queue.application_externaltaskmonitor_queue.arn}"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_sqs_queue_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "sqs.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_charge_processor_queue_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-charge_processor_queue_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the 'charge processor' SQS queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:ChangeMessageVisibilityBatch",
        "sqs:DeleteMessage",
        "sqs:DeleteMessageBatch",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListQueueTags",
        "sqs:ListQueues",
        "sqs:PurgeQueue",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:SendMessageBatch",
        "sqs:SetQueueAttributes",
        "sqs:TagQueue",
        "sqs:UntagQueue"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sqs_queue.application_charge_processor_queue.arn}",
        "${aws_sqs_queue.application_charge_processor_deadletter_queue.arn}"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.application_sqs_queue_kms_key.arn}",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "kms:ViaService": [
            "sqs.${var.aws_region}.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}

# SQS Queue Policy, enable Case Builder queue to be subscribed to the Event topic
resource "aws_sqs_queue_policy" "sns_event_topic_casebuilder_sqs_queue_access_policy" {
  queue_url = aws_sqs_queue.application_casebuilder_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action": [
       "sqs:SetQueueAttributes",
       "sqs:SendMessage"
     ],
     "Resource":"${aws_sqs_queue.application_casebuilder_queue.arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.application_event_topic.arn}"
       }
     }
  }]
}
POLICY
}


# SQS Queue Policy, enable Case Events queue to be subscribed to the Event topic
resource "aws_sqs_queue_policy" "sns_event_topic_case_events_sqs_queue_access_policy" {
  queue_url = aws_sqs_queue.application_caseevents_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action": [
       "sqs:SetQueueAttributes",
       "sqs:SendMessage"
     ],
     "Resource":"${aws_sqs_queue.application_caseevents_queue.arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.application_event_topic.arn}"
       }
     }
  }]
}
POLICY
}

# SQS Queue Policy, enable Activity Log queue to be subscribed to the Event topic
resource "aws_sqs_queue_policy" "sns_event_topic_activitylog_sqs_queue_access_policy" {
  queue_url = aws_sqs_queue.application_activitylog_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action":"sqs:SendMessage",
     "Resource":"${aws_sqs_queue.application_activitylog_queue.arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.application_event_topic.arn}"
       }
     }
  }]
}
POLICY
}

# SQS Queue Policy, enable Mu Notification queue to be subscribed to the Event topic
resource "aws_sqs_queue_policy" "sns_event_topic_munotification_sqs_queue_access_policy" {
  queue_url = aws_sqs_queue.application_munotification_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action":"sqs:SendMessage",
     "Resource":"${aws_sqs_queue.application_munotification_queue.arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.application_event_topic.arn}"
       }
     }
  }]
}
POLICY
}

# SQS Queue Policy, enable External Task Monitor queue to be subscribed to the Event topic
resource "aws_sqs_queue_policy" "sns_event_topic_externaltaskmonitor_sqs_queue_access_policy" {
  queue_url = aws_sqs_queue.application_externaltaskmonitor_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action":"sqs:SendMessage",
     "Resource":"${aws_sqs_queue.application_externaltaskmonitor_queue.arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.application_event_topic.arn}"
       }
     }
  }]
}
POLICY
}

# SQS Queue Policy, enable Charge Processor queue to be subscribed to the Event topic
resource "aws_sqs_queue_policy" "sns_event_topic_charge_processor_sqs_queue_access_policy" {
  queue_url = aws_sqs_queue.application_charge_processor_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Effect":"Allow",
     "Principal": {
       "AWS": "*"
     },
     "Action":"sqs:SendMessage",
     "Resource":"${aws_sqs_queue.application_charge_processor_queue.arn}",
     "Condition":{
       "ArnLike":{
         "aws:SourceArn": "${aws_sns_topic.application_event_topic.arn}"
       }
     }
  }]
}
POLICY
}

resource "aws_iam_policy" "aws_alb_ingress_controller_role_policy" {
  name        = "CodaMetrixApplication-${var.environment}-aws_alb_ingress_controller_role_policy"
  path        = var.iam_resource_path
  description = "This policy gives the 'AWS ALB Ingress Controller' access it needs to do it's job"

  # !!! Note: Is this too open?
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cognito-idp:DescribeUserPoolClient"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

# Route53 access policy to allow EKS to add resouce records (used during certificate creation)
resource "aws_iam_policy" "route53_resource_record_access_policy" {
  name        = "CodaMetrixApplication-${var.environment}-route53_resource_record_access_policy"
  path        = var.iam_resource_path
  description = "This policy gives EKS access it needs to create route53 resource records, used in cert creation"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets",
       "route53:ListHostedZonesByName",
       "route53:GetChange"
     ],
     "Resource": "*"
  }]
}
POLICY
}

# Cluster Autoscaler role that add more nodes
resource "aws_iam_policy" "asg_policy_for_autoscale_worker_node" {
  name        = "CodaMetrixApplication-${var.environment}-asg_policy_for_worker"
  path        = var.iam_resource_path
  description = "The Cluster Autoscaler requires the following IAM permissions to make calls to AWS APIs on your behalf."

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_describe_eks_clusters_policy" {
  name        = "CodaMetrixApplication-${var.environment}-describe_eks_clusters_policy"
  path        = var.iam_resource_path
  description = "This policy gives the ability to list and describe the application EKS cluster"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:ListClusters"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "${aws_eks_cluster.application_cluster.arn}"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_glue_full_access_policy" {
  name        = "CodaMetrixApplication-${var.environment}-glue_full_access_policy"
  path        = var.iam_resource_path
  description = "This policy gives the ability to perform all actions using AWS Glue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "glue:CreateDatabase",
        "glue:DeleteDatabase",
        "glue:GetDatabase",
        "glue:GetDatabases",
        "glue:UpdateDatabase",
        "glue:CreateTable",
        "glue:DeleteTable",
        "glue:BatchDeleteTable",
        "glue:UpdateTable",
        "glue:GetTable",
        "glue:GetTables",
        "glue:BatchCreatePartition",
        "glue:CreatePartition",
        "glue:DeletePartition",
        "glue:BatchDeletePartition",
        "glue:UpdatePartition",
        "glue:GetPartition",
        "glue:GetPartitions",
        "glue:BatchGetPartition"
      ],
      "Resource": [
          "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "application_redshift_misc_access_policy" {
  name        = "CodaMetrixApplication-${var.environment}-redshift_misc_access_policy"
  path        = var.iam_resource_path
  description = "This policy gives redshift the ability to perform several operations it needs for Spectrum"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetAccountPublicAccessBlock",
        "s3:ListAllMyBuckets",
        "s3:ListJobs",
        "s3:HeadBucket"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeAddresses",
        "ec2:AssociateAddress",
        "ec2:DisassociateAddress",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:ModifyNetworkInterfaceAttribute"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

###########################################
# Control Plane role and policy attachments
###########################################
resource "aws_iam_role" "eks_control_plane_role" {
  name               = "CodaMetrixApplication-${var.environment}-eks_control_plane_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives AWS EKS permissions to make API calls on our behalf"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - eks_control_plane_role"
      Type = "eks_control_plane_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_control_plane_cluster_policy_attachment" {
  role       = aws_iam_role.eks_control_plane_role.name
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
}

resource "aws_iam_role_policy_attachment" "eks_control_plane_service_policy_attachment" {
  role       = aws_iam_role.eks_control_plane_role.name
  policy_arn = data.aws_iam_policy.AmazonEKSServicePolicy.arn
}

resource "aws_iam_role_policy_attachment" "application_secrets_kms_key_usage_policy_attachment" {
  role       = aws_iam_role.eks_control_plane_role.name
  policy_arn = aws_iam_policy.application_secrets_kms_key_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_secrets_usage_policy_attachment" {
  role       = aws_iam_role.eks_control_plane_role.name
  policy_arn = aws_iam_policy.application_secrets_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_database_secrets_usage_policy_attachment" {
  role       = aws_iam_role.eks_control_plane_role.name
  policy_arn = aws_iam_policy.application_database_secrets_usage_policy.arn
}

##################################################
# Worker Node role, profile and policy attachments
##################################################
resource "aws_iam_role" "eks_node_instance_role" {
  name               = var.application_worker_node_instance_role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives K8S worker nodes permission to join the cluster"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - eks_node_instance_role"
      Type = "eks_node_instance_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
  role       = aws_iam_role.eks_node_instance_role.name
  policy_arn = data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_cni_policy_attachment" {
  role       = aws_iam_role.eks_node_instance_role.name
  policy_arn = data.aws_iam_policy.AmazonEKS_CNI_Policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_ecr_policy_attachment" {
  role       = aws_iam_role.eks_node_instance_role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}

# Enable the Cluster Autoscaler Service to add extra nodes as needed
resource "aws_iam_role_policy_attachment" "eks_worker_node_autoscaling_policy_attachment" {
  role       = aws_iam_role.application_cluster_autoscaler_role.name
  policy_arn = aws_iam_policy.asg_policy_for_autoscale_worker_node.arn
}

resource "aws_iam_instance_profile" "eks_node_instance_profile" {
  name = "CodaMetrixApplication-${var.environment}-eks_node_instance_profile"
  role = aws_iam_role.eks_node_instance_role.name
}

#######################################
# FluentD IAM role / policy attachments
#######################################
resource "aws_iam_role" "fluentd_role" {
  name = var.fluentd_role

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives FluentD containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - fluentd_role"
      Type = "fluentd_role"

    }
  )
}

resource "aws_iam_role_policy_attachment" "fluentd_application_elasticsearch_usage_policy_attachment" {
  role       = aws_iam_role.fluentd_role.name
  policy_arn = aws_iam_policy.application_elasticsearch_usage_policy.arn
}

##########################################################
# Kubernetes-Exteral-Secrets IAM role / policy attachments
##########################################################
resource "aws_iam_role" "application_k8s_ext_secrets_role" {
  name = var.kubernetes_external_secrets_role

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives 'Kubernetes External Secrets' containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_k8s_ext_secrets_role"
      Type = "application_k8s_ext_secrets_role"

    }
  )
}

resource "aws_iam_role_policy_attachment" "application_external_secrets_kms_key_usage_policy_attachment" {
  role       = aws_iam_role.application_k8s_ext_secrets_role.name
  policy_arn = aws_iam_policy.application_secrets_kms_key_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_external_secrets_usage_policy_attachment" {
  role       = aws_iam_role.application_k8s_ext_secrets_role.name
  policy_arn = aws_iam_policy.application_secrets_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_external_database_secrets_usage_policy_attachment" {
  role       = aws_iam_role.application_k8s_ext_secrets_role.name
  policy_arn = aws_iam_policy.application_database_secrets_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_external_oauth_process_secrets_usage_policy_attachment" {
  role       = aws_iam_role.application_k8s_ext_secrets_role.name
  policy_arn = aws_iam_policy.application_oauth_process_secrets_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_external_oauth_monitor_secrets_usage_policy_attachment" {
  role       = aws_iam_role.application_k8s_ext_secrets_role.name
  policy_arn = aws_iam_policy.application_oauth_monitor_secrets_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_external_mirth_database_secrets_usage_policy_attachment" {
  role       = aws_iam_role.application_k8s_ext_secrets_role.name
  policy_arn = module.mirth.mirth_database_secrets_usage_policy_arn
}

resource "aws_iam_role_policy_attachment" "application_external_ingress_mirth_database_secrets_usage_policy_attachment" {
  role       = aws_iam_role.application_k8s_ext_secrets_role.name
  policy_arn = module.ingress_mirth.mirth_database_secrets_usage_policy_arn
}

resource "aws_iam_role_policy_attachment" "new_relic_secrets_usage_policy_attachment" {
  role       = aws_iam_role.application_k8s_ext_secrets_role.name
  policy_arn = aws_iam_policy.new_relic_secrets_usage_policy.arn
}

###############################################
# ECR Cred Helper IAM role / policy attachments
###############################################
resource "aws_iam_role" "application_ecr_cred_helper_role" {
  name = var.ecr_cred_helper_role

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives 'ECR Cred Helper' containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_ecr_cred_helper_role"
      Type = "application_ecr_cred_helper_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecr_cred_helper_ecr_policy_attachment" {
  role       = aws_iam_role.application_ecr_cred_helper_role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}

##########################################################
# AWS ALB Ingress Controller IAM role / policy attachments
##########################################################
resource "aws_iam_role" "application_aws_alb_ingress_controller_role" {
  name = var.aws_alb_ingress_controller_role

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives 'AWS ALB Ingress Controller' containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_aws_alb_ingress_controller_role"
      Type = "application_aws_alb_ingress_controller_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "aws_alb_ingress_controller_role_policy_attachment" {
  role       = aws_iam_role.application_aws_alb_ingress_controller_role.name
  policy_arn = aws_iam_policy.aws_alb_ingress_controller_role_policy.arn
}

############################################
# AWS Redshift IAM role / policy attachments
############################################
resource "aws_iam_role" "application_redshift_role" {
  name = var.redshift_role

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "redshift.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Redshift access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_redshift_role"
      Type = "application_application_redshift_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "application_redshift_role_logs_bucket_policy_attachment" {
  role       = aws_iam_role.application_redshift_role.name
  policy_arn = aws_iam_policy.application_logs_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_redshift_role_data_lake_bucket_policy_attachment" {
  role       = aws_iam_role.application_redshift_role.name
  policy_arn = aws_iam_policy.application_data_lake_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_redshift_role_glue_full_access_policy_attachment" {
  role       = aws_iam_role.application_redshift_role.name
  policy_arn = aws_iam_policy.application_glue_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_redshift_role_misc_access_policy_attachment" {
  role       = aws_iam_role.application_redshift_role.name
  policy_arn = aws_iam_policy.application_redshift_misc_access_policy.arn
}

###############################################
# Cert Manager IAM role / policy attachments
###############################################
resource "aws_iam_role" "application_certmanager_role" {
  name = var.certmanager_role

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives 'CertManager' containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_certmanager_role"
      Type = "application_certmanager_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "application_certmanager_policy_attachment" {
  role       = aws_iam_role.application_certmanager_role.name
  policy_arn = aws_iam_policy.route53_resource_record_access_policy.arn
}

###################################################
# Microservice container roles / policy attachments
###################################################
# Process Service
resource "aws_iam_role" "application_processservice_role" {
  name = var.service_roles.processservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Process Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_processservice_role"
      Type = "application_processservice_role"
    }
  )
}

# Enable the Process Service to send messages via the "event" SNS topic
resource "aws_iam_role_policy_attachment" "application_processservice_role_topic_policy_attachment" {
  role       = aws_iam_role.application_processservice_role.name
  policy_arn = aws_iam_policy.application_event_topic_usage_policy.arn
}

#Attach Bucket Access Policy to Role
resource "aws_iam_role_policy_attachment" "application_processservice_role_bucket_policy_attachment" {
  role       = aws_iam_role.application_processservice_role.name
  policy_arn = aws_iam_policy.processservice_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_processservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_processservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_processservice_role_job_data_bucket_usage_policy" {
  role       = aws_iam_role.application_processservice_role.name
  policy_arn = aws_iam_policy.job_data_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_processservice_role_sagemaker_data_bucket_policy_attachment" {
  role       = aws_iam_role.application_processservice_role.name
  policy_arn = aws_iam_policy.sagemaker_data_bucket_usage_policy.arn
}

# Monitor Service
resource "aws_iam_role" "application_monitorservice_role" {
  name = var.service_roles.monitorservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Monitor Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_monitorservice_role"
      Type = "application_monitorservice_role"
    }
  )
}

# Enable the Monitor Service to send messages via the "event" SNS topic
resource "aws_iam_role_policy_attachment" "application_monitorservice_role_topic_policy_attachment" {
  role       = aws_iam_role.application_monitorservice_role.name
  policy_arn = aws_iam_policy.application_event_topic_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_monitorservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_monitorservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

# User Service
resource "aws_iam_role" "application_userservice_role" {
  name = var.service_roles.userservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives User Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_userservice_role"
      Type = "application_userservice_role"
    }
  )
}

# Enable the User Service to send messages via the "event" SNS topic
resource "aws_iam_role_policy_attachment" "application_userservice_role_topic_policy_attachment" {
  role       = aws_iam_role.application_userservice_role.name
  policy_arn = aws_iam_policy.application_event_topic_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_userservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_userservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

# Order Service
resource "aws_iam_role" "application_orderservice_role" {
  name = var.service_roles.orderservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Order Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_orderservice_role"
      Type = "application_orderservice_role"
    }
  )
}

# Enable the Order Service to send messages via the "event" SNS topic
resource "aws_iam_role_policy_attachment" "application_orderservice_role_topic_policy_attachment" {
  role       = aws_iam_role.application_orderservice_role.name
  policy_arn = aws_iam_policy.application_event_topic_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_orderservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_orderservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

# Importer Service
resource "aws_iam_role" "application_importerservice_role" {
  name = var.service_roles.importerservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Importer Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_importerservice_role"
      Type = "application_importerservice_role"
    }
  )
}

# Enable the Importer Service to send messages via the "event" SNS topic
resource "aws_iam_role_policy_attachment" "application_importerservice_role_topic_policy_attachment" {
  role       = aws_iam_role.application_importerservice_role.name
  policy_arn = aws_iam_policy.application_event_topic_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_importerservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_importerservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

# Patient Service
resource "aws_iam_role" "application_patientservice_role" {
  name = var.service_roles.patientservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Patient Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_patientservice_role"
      Type = "application_patientservice_role"
    }
  )
}

# Enable the Patient Service to send messages via the "event" SNS topic
resource "aws_iam_role_policy_attachment" "application_patientservice_role_topic_policy_attachment" {
  role       = aws_iam_role.application_patientservice_role.name
  policy_arn = aws_iam_policy.application_event_topic_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_patientservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_patientservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

# Claim Service
resource "aws_iam_role" "application_claimservice_role" {
  name = var.service_roles.claimservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Claim Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_claimservice_role"
      Type = "application_claimservice_role"
    }
  )
}

# Enable the Claim Service to send messages via the "event" SNS topic
resource "aws_iam_role_policy_attachment" "application_claimservice_role_topic_policy_attachment" {
  role       = aws_iam_role.application_claimservice_role.name
  policy_arn = aws_iam_policy.application_event_topic_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_claimservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_claimservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

# Case Service
resource "aws_iam_role" "application_caseservice_role" {
  name = var.service_roles.caseservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Case Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_caseservice_role"
      Type = "application_caseservice_role"
    }
  )
}

# Enable the Case Service to send messages via the "event" SNS topic
resource "aws_iam_role_policy_attachment" "application_caseservice_role_topic_policy_attachment" {
  role       = aws_iam_role.application_caseservice_role.name
  policy_arn = aws_iam_policy.application_event_topic_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_caseservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_caseservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

# Enable the Case Service to receive messages via the "casebuilder" SQS queue
resource "aws_iam_role_policy_attachment" "application_caseservice_role_casebuilder_queue_policy_attachment" {
  role       = aws_iam_role.application_caseservice_role.name
  policy_arn = aws_iam_policy.application_casebuilder_queue_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_caseservice_role_caseevents_queue_policy_attachment" {
  role       = aws_iam_role.application_caseservice_role.name
  policy_arn = aws_iam_policy.application_caseevents_queue_usage_policy.arn
}

# Enable case builder service access to charge processor queue
resource "aws_iam_role_policy_attachment" "application_caseservice_role_charge_processor_queue_policy_attachment" {
  role       = aws_iam_role.application_caseservice_role.name
  policy_arn = aws_iam_policy.application_charge_processor_queue_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_caseservice_role_create_queue_policy_attachment" {
  role       = aws_iam_role.application_caseservice_role.name
  policy_arn = aws_iam_policy.application_create_queue_policy.arn
}

# Enable the Case Service to write to the process data bucket.
resource "aws_iam_role_policy_attachment" "application_caseservice_role_processservice_bucket_policy_attachment" {
  role       = aws_iam_role.application_caseservice_role.name
  policy_arn = aws_iam_policy.processservice_bucket_usage_policy.arn
}

# Enable Case Builder to read/write the job data bucket
resource "aws_iam_role_policy_attachment" "application_caseservice_role_job_data_s3_policy_attachment" {
  role       = aws_iam_role.application_caseservice_role.name
  policy_arn = aws_iam_policy.job_data_bucket_usage_policy.arn
}

# Documentation Service
resource "aws_iam_role" "application_documentationservice_role" {
  name = var.service_roles.documentationservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Documentation Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_documentationservice_role"
      Type = "application_documentationservice_role"
    }
  )
}

# Enable the Documentation Service to read/write the documentation service buckets
resource "aws_iam_role_policy_attachment" "application_documentationservice_role_s3_policy_attachment" {
  role       = aws_iam_role.application_documentationservice_role.name
  policy_arn = aws_iam_policy.application_tenant_documents_bucket_usage_policy.arn
}

# Enable the EMR instance role to read the documentation service buckets
resource "aws_iam_role_policy_attachment" "application_emr_instance_role_document_bucket_policy_attachment" {
  role       = aws_iam_role.application_emr_instance_role.name
  policy_arn = aws_iam_policy.application_tenant_documents_bucket_read_only_policy.arn
}

# Enable the EMR service role to read the documentation service buckets
resource "aws_iam_role_policy_attachment" "application_emr_service_role_document_bucket_policy_attachment" {
  role       = aws_iam_role.application_emr_service_role.name
  policy_arn = aws_iam_policy.application_tenant_documents_bucket_read_only_policy.arn
}

# Event Dispatcher Service
resource "aws_iam_role" "application_eventdispatcherservice_role" {
  name = var.service_roles.eventdispatcherservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Event Dispatcher Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_eventdispatcherservice_role"
      Type = "application_eventdispatcherservice_role"
    }
  )
}

# Enable the Event Dispatcher Service to send/receive messages via the "event" SNS topic
resource "aws_iam_role_policy_attachment" "application_eventdispatcherservice_role_topic_policy_attachment" {
  role       = aws_iam_role.application_eventdispatcherservice_role.name
  policy_arn = aws_iam_policy.application_event_topic_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_eventdispatcherservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_eventdispatcherservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

# Enable the Event Dispatcher Service to forward messages via the various SQS queues
resource "aws_iam_role_policy_attachment" "application_eventdispatcherservice_role_casebuilder_queue_policy_attachment" {
  role       = aws_iam_role.application_eventdispatcherservice_role.name
  policy_arn = aws_iam_policy.application_casebuilder_queue_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_eventdispatcherservice_role_caseevents_queue_policy_attachment" {
  role       = aws_iam_role.application_eventdispatcherservice_role.name
  policy_arn = aws_iam_policy.application_caseevents_queue_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_eventdispatcherservice_role_activitylog_queue_policy_attachment" {
  role       = aws_iam_role.application_eventdispatcherservice_role.name
  policy_arn = aws_iam_policy.application_activitylog_queue_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_eventdispatcherservice_role_munotification_queue_policy_attachment" {
  role       = aws_iam_role.application_eventdispatcherservice_role.name
  policy_arn = aws_iam_policy.application_munotification_queue_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_eventdispatcherservice_role_externaltaskmonitor_queue_policy_attachment" {
  role       = aws_iam_role.application_eventdispatcherservice_role.name
  policy_arn = aws_iam_policy.application_externaltaskmonitor_queue_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_eventdispatcherservice_role_charge_processor_queue_policy_attachment" {
  role       = aws_iam_role.application_eventdispatcherservice_role.name
  policy_arn = aws_iam_policy.application_charge_processor_queue_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_eventdispatcherservice_role_create_queue_policy_attachment" {
  role       = aws_iam_role.application_eventdispatcherservice_role.name
  policy_arn = aws_iam_policy.application_create_queue_policy.arn
}

# Exporter Service
resource "aws_iam_role" "application_exporterservice_role" {
  name = var.service_roles.exporterservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF


  path        = var.iam_resource_path
  description = "This role gives Exporter Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_exporterservice_role"
      Type = "application_exporterservice_role"
    }
  )
}

# Dictionary Service
resource "aws_iam_role" "application_dictionaryservice_role" {
  name = var.service_roles.dictionaryservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Dictionary Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_dictionaryservice_role"
      Type = "application_dictionaryservice_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "application_dictionaryservice_role_create_topic_policy_attachment" {
  role       = aws_iam_role.application_dictionaryservice_role.name
  policy_arn = aws_iam_policy.application_create_topic_policy.arn
}

#######################################
# Mu roles / policies
#######################################

# Mu Sagemaker Service role
resource "aws_iam_role" "mu_sagemakerservice_role" {
  name = var.service_roles.musagemakerservice

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Mu Sagemaker Service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - mu_sagemakerservice_role"
      Type = "mu_sagemakerservice_role"
    }
  )
}

# Enable Mu sagemaker service to pull docker images
resource "aws_iam_role_policy_attachment" "mu_sagemakerservice_role_ecr_policy_attachment" {
  role       = aws_iam_role.mu_sagemakerservice_role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}

# Enable the Mu Sagemaker service to read/write the job data bucket
resource "aws_iam_role_policy_attachment" "mu_sagemakerservice_role_job_data_s3_policy_attachment" {
  role       = aws_iam_role.mu_sagemakerservice_role.name
  policy_arn = aws_iam_policy.job_data_bucket_usage_policy.arn
}

# Enable the Mu Sagemaker service to read the job manifest bucket
resource "aws_iam_role_policy_attachment" "mu_sagemakerservice_role_job_manifest_s3_policy_attachment" {
  role       = aws_iam_role.mu_sagemakerservice_role.name
  policy_arn = aws_iam_policy.job_manifest_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "mu_sagemakerservice_role_sagemaker_fullaccess_policy_attachment" {
  role       = aws_iam_role.mu_sagemakerservice_role.name
  policy_arn = data.aws_iam_policy.AmazonSageMakerFullAccessPolicy.arn
}

# Mu Default Task Execution role
resource "aws_iam_role" "mu_default_task_execution_role" {
  name = var.mu_default_task_execution_role

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sagemaker.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path                 = var.iam_resource_path
  description          = "This role gives Mu Sagemaker Tasks containers access to AWS resources"
  max_session_duration = 28800 # 8 hours, so that developers are able to work with sagemaker for a full day

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - mu_default_task_execution_role"
      Type = "mu_default_task_execution_role"
    }
  )
}

# Enable Mu default task execution role to pull docker images
resource "aws_iam_role_policy_attachment" "mu_default_task_execution_role_ecr_policy_attachment" {
  role       = aws_iam_role.mu_default_task_execution_role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}

resource "aws_iam_role_policy_attachment" "mu_default_task_execution_role_job_data_s3_policy_attachment" {
  role       = aws_iam_role.mu_default_task_execution_role.name
  policy_arn = aws_iam_policy.job_data_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "mu_default_task_execution_role_process_data_s3_policy_attachment" {
  role       = aws_iam_role.mu_default_task_execution_role.name
  policy_arn = aws_iam_policy.processservice_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "mu_default_task_execution_role_sagemaker_data_bucket_policy_attachment" {
  role       = aws_iam_role.mu_default_task_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_data_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "mu_default_task_execution_role_sagemaker_fullaccess_policy_attachment" {
  role       = aws_iam_role.mu_default_task_execution_role.name
  policy_arn = data.aws_iam_policy.AmazonSageMakerFullAccessPolicy.arn
}

resource "aws_iam_role_policy_attachment" "mu_default_task_execution_role_ephemeral_storage_key_policy_attachment" {
  role       = aws_iam_role.mu_default_task_execution_role.name
  policy_arn = aws_iam_policy.mu_sagemaker_ephemeral_storage_key_usage_policy.arn
}

#######################################
# RDS enhanced monitoring role / policy
#######################################
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "CodaMetrixApplication-${var.environment}-rds-enhanced-monitoring"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = data.aws_iam_policy.AmazonRDSEnhancedMonitoringRole.arn
}


#######################
# ElasticSearch service
#######################
resource "aws_iam_role" "es_kibana_cognito_role" {
  name = "CodaMetrixApplication-${var.environment}-es-kibana-cognito"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives ElasticSearch access to AWS Cognito resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - es_kibana_cognito_role"
      Type = "es_kibana_cognito_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "es_kibana_cognito_role_policy_attachment" {
  role       = aws_iam_role.es_kibana_cognito_role.name
  policy_arn = data.aws_iam_policy.AmazonESCognitoPolicy.arn
}

#######################################
# Cluster Autoscaler role / policy
#######################################

resource "aws_iam_role" "application_cluster_autoscaler_role" {
  name = var.cluster_autoscaler_service_role

  # Note: The following assume_role_policy is required by kube2iam
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks_node_instance_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives cluster autoscaler service containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_cluster_autoscale_service_role"
      Type = "application_cluster_autoscaler_service_role"
    }
  )
}

#######################################
# Cognito User Pool role / policy
#######################################

# !!! Disabling elasticsearch authentication for now...
# This role allows Cognito dispatch request to ElasticSearch after log in
# resource "aws_iam_role" "app_user_poolauth_role" {
#
#   name = "CMXApp-${var.environment}-cognito-es-app-user-poolauth-role"
#
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Federated": "cognito-identity.amazonaws.com"
#       },
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Condition": {
#         "StringEquals": {
#           "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.application_kibana_identity.id}"
#         },
#         "ForAnyValue:StringLike": {
#           "cognito-identity.amazonaws.com:amr": "authenticated"
#         }
#       }
#
#     }
#   ]
# }
# EOF
#
#   tags = merge(
#     var.shared_resource_tags,
#     {
#       Type = "app_user_poolauth_role"
#       Name = "CodaMetrix Application Cognito User Pool role- app_user_poolauth_role"
#     }
#   )
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_iam_role_policy" "app_user_poolauth_role_policy" {
#   name = "CMXApp-${var.environment}-app-user-poolauth-role-policy"
#   role = aws_iam_role.app_user_poolauth_role.id
#
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "mobileanalytics:PutEvents",
#         "cognito-sync:*",
#         "cognito-identity:*"
#       ],
#       "Resource": [
#         "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/*"
#       ]
#     }
#   ]
# }
# EOF
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_iam_role" "app_user_poolunauth_role" {
#
#   name = "CMXApp-${var.environment}-cognito-kibana-app-user-poolunauth-role"
#
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Federated": "cognito-identity.amazonaws.com"
#       },
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Condition": {
#         "StringEquals": {
#           "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.application_kibana_identity.id}"
#         },
#         "ForAnyValue:StringLike": {
#           "cognito-identity.amazonaws.com:amr": "unauthenticated"
#         }
#       }
#
#     }
#   ]
# }
# EOF
#
#   tags = merge(
#     var.shared_resource_tags,
#     {
#       Type = "app_user_poolunauth_role"
#       Name = "CodaMetrix Application Cognito User Pool- app_user_poolunauth_role"
#     }
#   )
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_iam_role_policy" "app_user_poolunauth_role_policy" {
#
#   name = "CMXApp-${var.environment}-app-user-poolunauth-role-policy"
#   role = aws_iam_role.app_user_poolunauth_role.id
#
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "mobileanalytics:PutEvents",
#         "cognito-sync:*"
#       ],
#       "Resource": [
#         "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/*"
#       ]
#     }
#   ]
# }
# EOF
# }

############################################
#  EMR roles
############################################
resource "aws_iam_role" "application_emr_service_role" {
  name = "CMXApp-${var.environment}-emr-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_emr_service_role"
      Type = "application_emr_service_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "application_emr_service_role_data_lake_bucket_policy_attachment" {
  role       = aws_iam_role.application_emr_service_role.name
  policy_arn = aws_iam_policy.application_data_lake_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_emr_service_role_logs_bucket_policy_attachment" {
  role       = aws_iam_role.application_emr_service_role.name
  policy_arn = aws_iam_policy.application_logs_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_emr_service_role_configuration_bucket_policy_attachment" {
  role       = aws_iam_role.application_emr_service_role.name
  policy_arn = aws_iam_policy.application_configuration_bucket_usage_policy.arn
}

resource "aws_iam_role_policy" "application_emr_service_role_map_reduce_policy" {
  name = "CMXApp-${var.environment}-application_emr_service_role_map_reduce_policy"
  role = aws_iam_role.application_emr_service_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CancelSpotInstanceRequests",
                "ec2:CreateNetworkInterface",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteTags",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribePrefixLists",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeVpcEndpointServices",
                "ec2:DescribeVpcs",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:RequestSpotInstances",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:DeleteVolume",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListInstanceProfiles",
                "iam:ListRolePolicies",
                "iam:PassRole",
                "s3:CreateBucket",
                "s3:Get*",
                "s3:List*",
                "sdb:BatchPutAttributes",
                "sdb:Select",
                "sqs:CreateQueue",
                "sqs:Delete*",
                "sqs:GetQueue*",
                "sqs:PurgeQueue",
                "sqs:ReceiveMessage",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DeleteAlarms",
                "application-autoscaling:RegisterScalableTarget",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:Describe*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "spot.amazonaws.com"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "application_emr_instance_role" {
  name = "CMXApp-${var.environment}-emr-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_emr_instance_role"
      Type = "application_emr_instance_role"
    }
  )
}

resource "aws_iam_instance_profile" "application_emr_instance_profile" {
  name = "CMXApp-${var.environment}-instance-profile"
  role = aws_iam_role.application_emr_instance_role.id
}

resource "aws_iam_role_policy" "application_emr_instance_profile_map_reduce_policy" {
  name = "CMXApp-${var.environment}-application_emr_instance_profile_map_reduce_policy"
  role = aws_iam_role.application_emr_instance_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "cloudwatch:*",
                "ec2:Describe*",
                "elasticmapreduce:Describe*",
                "elasticmapreduce:ListBootstrapActions",
                "elasticmapreduce:ListClusters",
                "elasticmapreduce:ListInstanceGroups",
                "elasticmapreduce:ListInstances",
                "elasticmapreduce:ListSteps",
                "s3:ListAllBuckets"
            ]
        },
        {
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:GenerateDataKey"
            ],
            "Effect": "Allow",
            "Resource": "${aws_kms_key.application_data_lake_emr_kms_key.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "application_emr_instance_role_data_lake_bucket_policy_attachment" {
  role       = aws_iam_role.application_emr_instance_role.name
  policy_arn = aws_iam_policy.application_data_lake_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_emr_instance_role_logs_bucket_policy_attachment" {
  role       = aws_iam_role.application_emr_instance_role.name
  policy_arn = aws_iam_policy.application_logs_bucket_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_emr_instance_role_configuration_bucket_policy_attachment" {
  role       = aws_iam_role.application_emr_instance_role.name
  policy_arn = aws_iam_policy.application_configuration_bucket_usage_policy.arn
}

resource "aws_iam_role" "application_emr_autoscaling_role" {
  name = "CMXApp-${var.environment}-application_emr_autoscaling_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "application-autoscaling.amazonaws.com",
          "elasticmapreduce.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_emr_autoscaling_role"
      Type = "application_emr_autoscaling_role"
    }
  )
}

resource "aws_iam_role_policy" "application_emr_autoscaling_policy" {
  name = "CMXApp-${var.environment}-application_emr_autoscaling_policy"
  role = aws_iam_role.application_emr_autoscaling_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:DescribeAlarms",
                "elasticmapreduce:ListInstanceGroups",
                "elasticmapreduce:ModifyInstanceGroups"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

###################################
# Data Lake Athena access resources
###################################
resource "aws_iam_user" "application_data_lake_additional_users" {
  count = length(var.data_lake_additional_users)
  name  = element(data.template_file.application_data_lake_athena_user_name.*.rendered, count.index)

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Application - application_data_lake_additional_users"
      Type     = "application_data_lake_additional_users"
      UserName = element(data.template_file.application_data_lake_athena_user_name.*.rendered, count.index)
    }
  )
}

resource "aws_iam_group" "application_data_lake_athena_users" {
  name = "CMXApp-${var.environment}-application_data_lake_athena_users"
  path = var.iam_resource_path
}

resource "aws_iam_group_membership" "application_data_lake_athena_users_membership" {
  name  = "CMXApp-${var.environment}-application_data_lake_athena_users_membership"
  users = aws_iam_user.application_data_lake_additional_users.*.name
  group = aws_iam_group.application_data_lake_athena_users.name
}

resource "aws_iam_group_policy_attachment" "application_data_lake_athena_users_athena_fullaccess_policy_attachment" {
  group      = aws_iam_group.application_data_lake_athena_users.name
  policy_arn = data.aws_iam_policy.AmazonAthenaFullAccess.arn
}

resource "aws_iam_group_policy_attachment" "application_data_lake_athena_users_data_lake_bucket_policy_attachment" {
  group      = aws_iam_group.application_data_lake_athena_users.name
  policy_arn = aws_iam_policy.application_data_lake_bucket_readonly_policy.arn
}

resource "aws_iam_group_policy_attachment" "application_data_lake_athena_users_output_bucket_policy_attachment" {
  group      = aws_iam_group.application_data_lake_athena_users.name
  policy_arn = aws_iam_policy.application_data_lake_athena_output_bucket_usage_policy.arn
}

##################################################

############################################
#  VPC flow log role
############################################
resource "aws_iam_role" "vpc_flow_log_service_role" {
  name = "CMXApp-${var.environment}-vpc_flow_log_service_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - vpc_flow_log_service_role"
      Type = "vpc_flow_log_service_role"
    }
  )
}

resource "aws_iam_role_policy" "vpc_flow_log_service_role_policy" {

  name = "CMXApp-${var.environment}-vpc_flow_log_service_role_policy"
  role = aws_iam_role.vpc_flow_log_service_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
##################################################
##################################################
# Kinesis Stream related roles amd policies
##################################################
# Role for the transformation Lambda function attached to the kinesis stream
resource "aws_iam_role" "cloud_watch_ingest_to_es_role" {
  # name can not be longer than 64 characters
  name        = "CMXApplication-${var.environment}-cloud_watch_ingest_to_es_role"
  description = "Role for Lambda function to transformation CloudWatch logs into ElasticSearch compatible format"

  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "cloud_watch_ingest_to_es_role"
      Name = "CodaMetrix Application IAM - cloud_watch_ingest_to_es_role"
    }
  )
}

data "aws_iam_policy_document" "cloudwatch_get_logevent_lambda_policy_doc" {
  for_each = var.cloud_watch_ingest_to_elasticsearch_log_groups
  statement {
    actions = [
      "logs:GetLogEvents",
    ]

    resources = [
      each.value.arn,
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "cloudwatch_ingest_to_es_by_firehose_lambda_policy_doc" {
  for_each = var.cloud_watch_ingest_to_elasticsearch_log_groups

  statement {
    actions = [
      "kinesis:PutRecords"
    ]

    resources = [
      aws_kinesis_stream.kinesis_stream_to_push_cloudwatch_log_group_to_es[each.key].arn,
    ]
  }

  statement {
    actions = [
      "firehose:PutRecordBatch",
      "firehose:PutRecord"
    ]

    resources = [
      aws_kinesis_firehose_delivery_stream.cloudwatch_to_es[each.key].arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
}


resource "aws_iam_policy" "cloud_watch_ingest_to_es_firehose_lambda_transform_policy" {
  for_each = var.cloud_watch_ingest_to_elasticsearch_log_groups
  name     = "CMXApplication-${var.environment}-${random_string.upper_case_string[each.key].result}-cloud_watch_ingest_to_es_firehose_lambda_transform_policy"
  policy   = data.aws_iam_policy_document.cloudwatch_ingest_to_es_by_firehose_lambda_policy_doc[each.key].json
}

resource "aws_iam_role_policy_attachment" "cloud_watch_ingest_to_es_firehose_lambda_function_role_policy_attachment" {
  for_each   = var.cloud_watch_ingest_to_elasticsearch_log_groups
  role       = aws_iam_role.cloud_watch_ingest_to_es_role.name
  policy_arn = aws_iam_policy.cloud_watch_ingest_to_es_firehose_lambda_transform_policy[each.key].arn
}

resource "aws_iam_policy" "cloud_watch_ingest_to_es_lambda_transform_policy" {
  for_each = var.cloud_watch_ingest_to_elasticsearch_log_groups
  name     = "CMXApplication-${var.environment}-${random_string.upper_case_string[each.key].result}-cloud_watch_ingest_to_es_lambda_transform_policy"
  policy   = data.aws_iam_policy_document.cloudwatch_get_logevent_lambda_policy_doc[each.key].json
}

resource "aws_iam_role_policy_attachment" "cloud_watch_ingest_to_es_lambda_policy_role_attachment" {
  for_each   = var.cloud_watch_ingest_to_elasticsearch_log_groups
  role       = aws_iam_role.cloud_watch_ingest_to_es_role.name
  policy_arn = aws_iam_policy.cloud_watch_ingest_to_es_lambda_transform_policy[each.key].arn
}

resource "aws_iam_role" "cloudwatch_log_access_to_kinesis_stream_role" {
  # name can not be longer than 64 characters.
  name        = "CMXApplication-${var.environment}-cw_log_access_to_kinesis_stream_role"
  description = "Role for CloudWatch Log Group subscription"

  assume_role_policy = <<ROLE
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "logs.${var.aws_region}.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
ROLE

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "cloudwatch_log_access_to_kinesis_stream_role"
      Name = "CodaMetrix Application Kinesis - cloudwatch_log_access_to_kinesis_stream_role"
    }
  )
}


data "aws_iam_policy_document" "cloudwatch_to_kinesis_stream_access_policy" {
  for_each = var.cloud_watch_ingest_to_elasticsearch_log_groups
  statement {
    actions = [
      "kinesis:*",
    ]

    effect = "Allow"

    resources = [
      aws_kinesis_stream.kinesis_stream_to_push_cloudwatch_log_group_to_es[each.key].arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "iam:PassRole",
    ]

    effect = "Allow"

    resources = [
      aws_iam_role.cloudwatch_log_access_to_kinesis_stream_role.arn,
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_to_kinesis_stream_access_policy" {
  for_each    = var.cloud_watch_ingest_to_elasticsearch_log_groups
  name        = "CMXApplication-${var.environment}-${random_string.upper_case_string[each.key].result}-cloudwatch_to_kinesis_stream_access_policy"
  description = "Cloudwatch to Firehose Subscription Policy"
  policy      = data.aws_iam_policy_document.cloudwatch_to_kinesis_stream_access_policy[each.key].json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_to_kinesis_stream_policy_attachment" {
  for_each   = var.cloud_watch_ingest_to_elasticsearch_log_groups
  role       = aws_iam_role.cloudwatch_log_access_to_kinesis_stream_role.name
  policy_arn = aws_iam_policy.cloudwatch_to_kinesis_stream_access_policy[each.key].arn
}

resource "aws_iam_role" "firehose_to_elastic_search_role" {
  name               = "CMXApplication-${var.environment}-firehose_to_elastic_search_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "firehose_to_elastic_search_role"
      Name = "CodaMetrix Application Kinesis - firehose_to_elastic_search_role"
    }
  )
}

# Policy to let firehose access different resources
resource "aws_iam_policy" "firehose_push_to_elasticsearch_config_policy" {
  name     = "CMXApplication-${var.environment}-${random_string.upper_case_string[each.key].result}-firehose_push_to_elasticsearch_config_policy"
  for_each = var.cloud_watch_ingest_to_elasticsearch_log_groups
  path     = var.iam_resource_path
  policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.application_logs_bucket.arn}",
                "${aws_s3_bucket.application_logs_bucket.arn}/*"
            ]
        },
        {
           "Effect": "Allow",
           "Action": [
              "ec2:Describe*",
              "ec2:DescribeVpcAttribute",
              "ec2:DescribeSubnets",
              "ec2:DescribeSecurityGroups",
              "ec2:DescribeNetworkInterfaces",
              "ec2:CreateNetworkInterface",
              "ec2:CreateNetworkInterfacePermission",
              "ec2:DeleteNetworkInterface"
           ],
          "Resource": "*"
       },
      {
           "Effect": "Allow",
           "Action": [
               "kms:Decrypt",
               "kms:GenerateDataKey"
           ],
           "Resource": [
               "${aws_kms_key.application_kinesis_kms_key.arn}"
           ],
           "Condition": {
               "StringEquals": {
                   "kms:ViaService": "s3.${var.aws_region}.amazonaws.com"
               },
               "StringLike": {
                   "kms:EncryptionContext:aws:s3:arn": "${aws_s3_bucket.application_logs_bucket.arn}/${var.firehose_s3_backup_bucket_configuration_prefix}*"
               }
           }
        },
        {
           "Effect": "Allow",
           "Action": [
               "es:DescribeElasticsearchDomain",
               "es:DescribeElasticsearchDomains",
               "es:DescribeElasticsearchDomainConfig",
               "es:ESHttpPost",
               "es:ESHttpPut"
           ],
          "Resource": [
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}",
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/*"
          ]
       },
       {
          "Effect": "Allow",
          "Action": [
              "es:ESHttpGet"
          ],
          "Resource": [
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/_all/_settings",
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/_cluster/stats",
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/index-name*/_mapping/type-name",
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/_nodes",
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/_nodes/stats",
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/_nodes/*/stats",
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/_stats",
              "${aws_elasticsearch_domain.application_elasticsearch_domain.arn}/index-name*/_stats"
          ]
       },
       {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents"
          ],
          "Resource": [
              "arn:aws:logs:*"
          ]
       },
       {
          "Effect": "Allow",
          "Action": [
              "kinesis:Get*",
              "kinesis:DescribeStream",
              "kinesis:GetShardIterator",
              "kinesis:GetRecords",
              "kinesis:ListShards"
          ],
          "Resource": "${aws_kinesis_stream.kinesis_stream_to_push_cloudwatch_log_group_to_es[each.key].arn}"
       },
       {
          "Effect": "Allow",
          "Action": [
              "lambda:InvokeFunction",
              "lambda:GetFunctionConfiguration"
          ],
          "Resource": [
              "${aws_lambda_function.cloudwatch_log_groups_to_es.arn}:$LATEST"
          ]
       },
       {
          "Effect": "Allow",
          "Action": [
              "logs:PutLogEvents"
          ],
          "Resource": [
              "${aws_cloudwatch_log_group.cloud_watch_ingest_to_es_by_kinesis_firehose_log_group[each.key].arn}"
          ]
       }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_push_to_elasticsearch_config_policy_firehose_to_elastic_search_role_attachment" {
  for_each   = var.cloud_watch_ingest_to_elasticsearch_log_groups
  role       = aws_iam_role.firehose_to_elastic_search_role.name
  policy_arn = aws_iam_policy.firehose_push_to_elasticsearch_config_policy[each.key].arn
}

##################################################
# End of Kinesis Stream related roles and policies
##################################################

##################################################
# CloudWatch Alarm related roles and policies
##################################################
data "aws_iam_policy_document" "application_high_priority_alarm_topic_policy_doc" {
  statement {

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect    = "Allow"
    resources = [aws_sns_topic.application_high_priority_alarm_topic.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
  }

}

resource "aws_sns_topic_policy" "application_high_priority_alarm_topic_policy" {
  arn    = aws_sns_topic.application_high_priority_alarm_topic.arn
  policy = data.aws_iam_policy_document.application_high_priority_alarm_topic_policy_doc.json
}

data "aws_iam_policy_document" "application_medium_priority_alarm_topic_policy_doc" {
  statement {

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect    = "Allow"
    resources = [aws_sns_topic.application_medium_priority_alarm_topic.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
  }

}

resource "aws_sns_topic_policy" "application_medium_priority_alarm_topic_policy" {
  arn    = aws_sns_topic.application_medium_priority_alarm_topic.arn
  policy = data.aws_iam_policy_document.application_medium_priority_alarm_topic_policy_doc.json
}

data "aws_iam_policy_document" "application_low_priority_alarm_topic_policy_doc" {
  statement {

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect    = "Allow"
    resources = [aws_sns_topic.application_low_priority_alarm_topic.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
  }

}

resource "aws_sns_topic_policy" "application_low_priority_alarm_topic_policy" {
  arn    = aws_sns_topic.application_low_priority_alarm_topic.arn
  policy = data.aws_iam_policy_document.application_low_priority_alarm_topic_policy_doc.json
}

###################################################################
# EKS role, for individuals who need access to work with kubernetes
###################################################################
resource "aws_iam_role" "application_eks_user_role" {
  name               = "CMXApplication-${var.environment}-application_eks_user_role"
  assume_role_policy = data.aws_iam_policy_document.sso_assume_role_policy_document.json
  path               = var.iam_resource_path
  description        = "This role gives user access to AWS EKS clusters"

  # 8 hours
  max_session_duration = 28800

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_eks_user_role"
      Type = "application_eks_user_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "application_eks_user_role_access_policy_attachments" {
  role       = aws_iam_role.application_eks_user_role.name
  policy_arn = aws_iam_policy.application_eks_access_policy.arn
}

####################################################
# End of CloudWatch Alarm related roles and policies
####################################################

##################################################################
# Roles and policies related to rotation of Elasticsearch indices
##################################################################
resource "aws_iam_role" "elasticsearch_rotate_index_role" {
  # name can not be longer than 64 characters
  name        = "CMXApplication-${var.environment}-elasticsearch_rotate_index_role"
  description = "Role for Lambda function to rotate ElasticSearch indices"

  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "es.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
  path               = var.iam_resource_path

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "elasticsearch_rotate_index_role"
      Name = "CodaMetrix Application IAM - elasticsearch_rotate_index_role"
    }
  )
}

resource "aws_iam_policy" "elasticsearch_rotate_index_lambda_role_policy" {
  depends_on = [aws_s3_bucket.elasticsearch_index_backup_bucket]
  for_each   = var.elasticsearch_index_rotation
  name       = "CMXApplication-${var.environment}-${each.key}_elasticsearch_rotate_index_lambda_role_policy"
  path       = var.iam_resource_path
  policy     = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Action":[
                "s3:ListBucket"
            ],
            "Effect":"Allow",
            "Resource":[
               "${aws_s3_bucket.elasticsearch_index_backup_bucket[each.key].arn}"
            ]
        },
        {
            "Action":[
                "s3:*"
            ],
            "Effect":"Allow",
            "Resource":[
               "${aws_s3_bucket.elasticsearch_index_backup_bucket[each.key].arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZonesByName",
                "route53:ListHostedZones",
                "route53:GetHostedZone",
                "route53:ListResourceRecordSets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "elasticsearch_rotate_index_lambda_role_policy_rotate_index_lambda_role_attachment" {
  for_each   = var.elasticsearch_index_rotation
  role       = aws_iam_role.elasticsearch_rotate_index_role.name
  policy_arn = aws_iam_policy.elasticsearch_rotate_index_lambda_role_policy[each.key].arn
}

########################################################################
# End of roles and policies related to rotation of Elasticsearch indices
########################################################################

###########################
# Kibana publish alarm role
###########################
resource "aws_iam_role" "application_kibana_alarm_topic_push_role" {
  name               = "CMXApplication-${var.environment}-kibana_alarm_topic_push_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Kibana access to publish messages to the alarm topics"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_kibana_alarm_topic_push_role"
      Type = "application_kibana_alarm_topic_push_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "application_kibana_alarm_topic_push_role_policy_attachments" {
  role       = aws_iam_role.application_kibana_alarm_topic_push_role.name
  policy_arn = aws_iam_policy.application_alarm_topic_usage_policy.arn
}

resource "aws_iam_policy" "application_alarm_topic_usage_policy" {
  name        = "CodaMetrixApplication-${var.environment}-alarm_topic_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives publish access to the various alarm level SNS topics"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sns_topic.application_high_priority_alarm_topic.arn}",
        "${aws_sns_topic.application_medium_priority_alarm_topic.arn}",
        "${aws_sns_topic.application_low_priority_alarm_topic.arn}"
      ]
    }
  ]
}
POLICY
}
##################################################
# End of Kibana Alarm related roles amd policies
##################################################

##################################################################
# Roles and policies needed to allow S3 replication to DR envs
##################################################################

resource "aws_iam_role" "s3_replication_role" {
  description = "Role that allows S3 replication to DR envs"
  name        = "CMXApplication-${var.environment}-s3-replication-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# NOTE: Encrypt cannot be locked down any further without
# gathering kms key data for each dr_region key. An attempt to lockdown by
# alias ARN failed
resource "aws_iam_policy" "s3_replication_policy" {
  description = "Policy allowing S3 replication and KMS encrypt/decrypt"
  name        = "CMXApplication-${var.environment}-s3-replication-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action":[
        "s3:GetReplicationConfiguration",
        "s3:ListBucket",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging",
        "s3:GetObjectVersionForReplication",
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::*"
      ]
    },
    {
      "Action":[
        "kms:Decrypt"
      ],
      "Effect":"Allow",
      "Condition": {
        "StringLike": {
          "kms:ViaService":"s3.${var.aws_region}.amazonaws.com"
        }
      },
      "Resource":[
        "${aws_kms_alias.job_data_bucket_key_alias.target_key_arn}",
        "${aws_kms_alias.process_data_bucket_key_alias.target_key_arn}",
        "${aws_kms_alias.application_data_lake_emr_kms_key_alias.target_key_arn}",
        ${join(", ", formatlist(local.json_list_item, values(aws_kms_key.application_healthsystem_kms_key).*.arn))},
        "${data.aws_kms_key.aws_s3_kms_key.arn}"
      ]
    },
    {
      "Action":[
        "kms:Encrypt"
      ],
      "Effect":"Allow",
      "Condition": {
        "StringLike": {
          "kms:ViaService": "s3.${var.dr_region}.amazonaws.com"
        }
      },
      "Resource":[
        "${local.iam_dr_kms_arn_prefix}key/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "s3_replication_attachment" {
  role       = aws_iam_role.s3_replication_role.name
  policy_arn = aws_iam_policy.s3_replication_policy.arn
}

################################
# Developer role, for SSO access
################################
resource "aws_iam_role" "application_developer_role" {
  name                  = "CMXApplication-${var.environment}-application_developer_role"
  assume_role_policy    = data.aws_iam_policy_document.sso_assume_role_policy_document.json
  path                  = var.iam_resource_path
  description           = "This role gives developer access to the individual who assumes it"

  # 8 hours
  max_session_duration  = 28800

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_developer_role"
      Type = "application_developer_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "application_developer_role_ecr_policy_attachment" {
  role       = aws_iam_role.application_developer_role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}

resource "aws_iam_role_policy_attachment" "application_developer_role_sagemaker_policy_attachment" {
  role       = aws_iam_role.application_developer_role.name
  policy_arn = data.aws_iam_policy.AmazonSageMakerFullAccessPolicy.arn
}

resource "aws_iam_role_policy_attachment" "application_developer_role_s3_policy_attachment" {
  role       = aws_iam_role.application_developer_role.name
  policy_arn = aws_iam_policy.application_developers_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_developer_role_sqs_policy_attachment" {
  role       = aws_iam_role.application_developer_role.name
  policy_arn = aws_iam_policy.application_developers_sqs_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_developer_role_misc_policy_attachment" {
  role       = aws_iam_role.application_developer_role.name
  policy_arn = aws_iam_policy.application_developers_misc_access_policy.arn
}

########################################################################
# End of roles and policies needed to allow S3 replication to DR envs
########################################################################

output "eks_control_plane_role_arn" {
  value = aws_iam_role.eks_control_plane_role.arn
}

output "eks_node_instance_role_arn" {
  value = aws_iam_role.eks_node_instance_role.arn
}

output "eks_node_instance_profile_arn" {
  value = aws_iam_instance_profile.eks_node_instance_profile.arn
}

output "application_certmanager_role_arn" {
  value = aws_iam_role.application_certmanager_role.arn
}

output "application_redshift_role_arn" {
  value = aws_iam_role.application_redshift_role.arn
}
