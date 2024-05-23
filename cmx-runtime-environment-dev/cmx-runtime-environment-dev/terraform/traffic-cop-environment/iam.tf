######################
# AWS Managed Policies
######################
data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "AmazonRDSEnhancedMonitoringRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

locals {
  json_list_item = <<STRING
"%s"
STRING

  s3_bucket_contents_list_item = <<STRING
"%s/*"
STRING
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
# Engineer Policies
######################
resource "aws_iam_policy" "engineers_s3_access_policy" {
  name        = "CMXTrafficCop-${var.environment}-engineers_s3_access_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to platform S3 buckets for engineers"

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

######################
# Platform policies
######################
resource "aws_iam_policy" "secrets_kms_key_usage_policy" {
  name        = "CMXTrafficCop-${var.environment}-secrets_kms_key_usage_policy"
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
      "Resource": "${aws_kms_key.secrets_kms_key.arn}",
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

resource "aws_iam_policy" "new_relic_secrets_usage_policy" {
  name        = "CMXTrafficCop-${var.environment}-new_relic_secrets_usage_policy"
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

resource "aws_iam_policy" "elasticsearch_usage_policy" {
  name        = "CMXTrafficCop-${var.environment}-elasticsearch_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to all elasticsearch HTTP methods"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["es:ESHttp*"],
      "Resource": "${aws_elasticsearch_domain.elasticsearch_domain.arn}/*"
    }
  ]
}
POLICY
}

# Configuration Bucket Policy
resource "aws_iam_policy" "configuration_bucket_usage_policy" {
  name        = "CMXTrafficCop-${var.environment}-configuration_bucket_usage_policy"
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
        "${aws_s3_bucket.configuration_bucket.arn}",
        "${aws_s3_bucket.configuration_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "logs_bucket_usage_policy" {
  name        = "CMXTrafficCop-${var.environment}-logs_bucket_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives read/write access to the logs bucket"

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
        "${aws_s3_bucket.logs_bucket.arn}",
        "${aws_s3_bucket.logs_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

# Mirth Temp Bucket Policy
resource "aws_iam_policy" "mirth_temp_bucket_usage_policy" {
  name        = "CMXTrafficCop-${var.environment}-mirth_temp_bucket_usage_policy"
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

#######################################
# RDS enhanced monitoring role / policy
#######################################
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "CMXTrafficCop-${var.environment}-rds-enhanced-monitoring"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = data.aws_iam_policy.AmazonRDSEnhancedMonitoringRole.arn
}

############################################
#  VPC flow log role
############################################
resource "aws_iam_role" "vpc_flow_log_service_role" {
  name = "CMXTrafficCop-${var.environment}-vpc_flow_log_service_role"

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
      Name = "CodaMetrix Traffic Cop - vpc_flow_log_service_role"
      Type = "vpc_flow_log_service_role"
    }
  )
}

resource "aws_iam_role_policy" "vpc_flow_log_service_role_policy" {
  name = "CMXTrafficCop-${var.environment}-vpc_flow_log_service_role_policy"
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
# Kinesis Stream related roles amd policies
##################################################
# Role for the transformation Lambda function attached to the kinesis stream
resource "aws_iam_role" "cloud_watch_ingest_to_es_role" {
  # name can not be longer than 64 characters
  name        = "CMXTrafficCop-${var.environment}-cloud_watch_ingest_to_es_role"
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
      Name = "CodaMetrix Traffic Cop IAM - cloud_watch_ingest_to_es_role"
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
  name     = "CMXTrafficCop-${var.environment}-${random_string.upper_case_string[each.key].result}-cloud_watch_ingest_to_es_firehose_lambda_transform_policy"
  policy   = data.aws_iam_policy_document.cloudwatch_ingest_to_es_by_firehose_lambda_policy_doc[each.key].json
}

resource "aws_iam_role_policy_attachment" "cloud_watch_ingest_to_es_firehose_lambda_function_role_policy_attachment" {
  for_each   = var.cloud_watch_ingest_to_elasticsearch_log_groups
  role       = aws_iam_role.cloud_watch_ingest_to_es_role.name
  policy_arn = aws_iam_policy.cloud_watch_ingest_to_es_firehose_lambda_transform_policy[each.key].arn
}

resource "aws_iam_policy" "cloud_watch_ingest_to_es_lambda_transform_policy" {
  for_each = var.cloud_watch_ingest_to_elasticsearch_log_groups
  name     = "CMXTrafficCop-${var.environment}-${random_string.upper_case_string[each.key].result}-cloud_watch_ingest_to_es_lambda_transform_policy"
  policy   = data.aws_iam_policy_document.cloudwatch_get_logevent_lambda_policy_doc[each.key].json
}

resource "aws_iam_role_policy_attachment" "cloud_watch_ingest_to_es_lambda_policy_role_attachment" {
  for_each   = var.cloud_watch_ingest_to_elasticsearch_log_groups
  role       = aws_iam_role.cloud_watch_ingest_to_es_role.name
  policy_arn = aws_iam_policy.cloud_watch_ingest_to_es_lambda_transform_policy[each.key].arn
}

resource "aws_iam_role" "cloudwatch_log_access_to_kinesis_stream_role" {
  # name can not be longer than 64 characters.
  name        = "CMXTrafficCop-${var.environment}-cw_log_access_to_kinesis_stream_role"
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
      Name = "CodaMetrix Traffic Cop IAM - cloudwatch_log_access_to_kinesis_stream_role"
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
  name        = "CMXTrafficCop-${var.environment}-${random_string.upper_case_string[each.key].result}-cloudwatch_to_kinesis_stream_access_policy"
  description = "Cloudwatch to Firehose Subscription Policy"
  policy      = data.aws_iam_policy_document.cloudwatch_to_kinesis_stream_access_policy[each.key].json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_to_kinesis_stream_policy_attachment" {
  for_each   = var.cloud_watch_ingest_to_elasticsearch_log_groups
  role       = aws_iam_role.cloudwatch_log_access_to_kinesis_stream_role.name
  policy_arn = aws_iam_policy.cloudwatch_to_kinesis_stream_access_policy[each.key].arn
}

resource "aws_iam_role" "firehose_to_elastic_search_role" {
  name               = "CMXTrafficCop-${var.environment}-firehose_to_elastic_search_role"
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
      Name = "CodaMetrix Traffic Cop IAM - firehose_to_elastic_search_role"
    }
  )
}

# Policy to let firehose access different resources
resource "aws_iam_policy" "firehose_push_to_elasticsearch_config_policy" {
  name     = "CMXTrafficCop-${var.environment}-${random_string.upper_case_string[each.key].result}-firehose_push_to_elasticsearch_config_policy"
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
                "${aws_s3_bucket.logs_bucket.arn}",
                "${aws_s3_bucket.logs_bucket.arn}/*"
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
               "${aws_kms_key.kinesis_kms_key.arn}"
           ],
           "Condition": {
               "StringEquals": {
                   "kms:ViaService": "s3.${var.aws_region}.amazonaws.com"
               },
               "StringLike": {
                   "kms:EncryptionContext:aws:s3:arn": "${aws_s3_bucket.logs_bucket.arn}/${var.firehose_s3_backup_bucket_configuration_prefix}*"
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
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}",
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}/*"
          ]
       },
       {
          "Effect": "Allow",
          "Action": [
              "es:ESHttpGet"
          ],
          "Resource": [
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}/_all/_settings",
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}/_cluster/stats",
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}/index-name*/_mapping/type-name",
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}/_nodes",
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}/_nodes/stats",
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}/_nodes/*/stats",
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}/_stats",
              "${aws_elasticsearch_domain.elasticsearch_domain.arn}/index-name*/_stats"
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
data "aws_iam_policy_document" "cloudwatch_alarm_sns_topic_access_policy_doc" {
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
    resources = [aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn]

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

resource "aws_sns_topic_policy" "cloudwatch_alarm_publish_to_sns_topic_policy" {
  arn    = aws_sns_topic.cloudwatch_alarm_push_alerts_topic.arn
  policy = data.aws_iam_policy_document.cloudwatch_alarm_sns_topic_access_policy_doc.json
}

##################################################################
# Roles and policies related to rotation of Elasticsearch indices
##################################################################
resource "aws_iam_role" "elasticsearch_rotate_index_role" {
  # name can not be longer than 64 characters
  name        = "CMXTrafficCop-${var.environment}-elasticsearch_rotate_index_role"
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
  path                  = var.iam_resource_path

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "elasticsearch_rotate_index_role"
      Name = "CodaMetrix Traffic Cop IAM - elasticsearch_rotate_index_role"
    }
  )
}

resource "aws_iam_policy" "elasticsearch_rotate_index_lambda_role_policy" {
  depends_on = [aws_s3_bucket.elasticsearch_index_backup_bucket]
  for_each   = var.elasticsearch_index_rotation
  name       = "CMXTrafficCop-${var.environment}-${each.key}_elasticsearch_rotate_index_lambda_role_policy"
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
resource "aws_iam_role" "kibana_alarm_topic_push_role" {
  name                  = "CMXTrafficCop-${var.environment}-kibana_alarm_topic_push_role"
  assume_role_policy    = <<EOF
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

  path                  = var.iam_resource_path
  description           = "This role gives Kibana access to publish messages to the alarm topic"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Traffic Cop IAM - kibana_alarm_topic_push_role"
      Type = "kibana_alarm_topic_push_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "kibana_alarm_topic_push_role_policy_attachments" {
  role       = aws_iam_role.kibana_alarm_topic_push_role.name
  policy_arn = aws_iam_policy.kibana_alarm_topic_usage_policy.arn
}

resource "aws_iam_policy" "kibana_alarm_topic_usage_policy" {
  name        = "CMXTrafficCop-${var.environment}-kibana_alarm_topic_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives publish access to the 'kibana' SNS topic"

  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sns_topic.kibana_alarm_push_alerts_topic.arn}"
      ]
    }
  ]
}
POLICY
}
##################################################
# End of Kibana Alarm related roles and policies
##################################################

#######################
#  Inspector event role
#######################
resource "aws_iam_role" "inspector_event_role" {
  name  = "CMXTrafficCop-${var.environment}-inspector_event_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "inspector_event_policy" {
  name   = "CMXTrafficCop-${var.environment}-inspector_event_policy"
  role   = aws_iam_role.inspector_event_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "inspector:StartAssessmentRun"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
