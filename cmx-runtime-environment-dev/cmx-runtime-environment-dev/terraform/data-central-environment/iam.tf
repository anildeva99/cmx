######################
# AWS Managed Policies
######################

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
# Developers Policies
#####################
resource "aws_iam_policy" "environment_developers_misc_access_policy" {
  name        = "CodaMetrixDataCentral-${var.environment}-developers_misc_access_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to additional platform resources for developers"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetAccountPublicAccessBlock",
        "s3:ListAllMyBuckets",
        "s3:HeadBucket"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "environment_developer_role" {
  name                  = "CMXDataCentral-${var.environment}-environment_developer_role"
  assume_role_policy    = data.aws_iam_policy_document.sso_assume_role_policy_document.json
  path                  = var.iam_resource_path
  description           = "This role gives developer access to the individual who assumes it"

  # 8 hours
  max_session_duration  = 28800

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central - environment_developer_role"
      Type = "environment_developer_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "environment_developer_role_misc_access_policy_attachment" {
  role       = aws_iam_role.environment_developer_role.name
  policy_arn = aws_iam_policy.environment_developers_misc_access_policy.arn
}


######################
# Environment policies
######################
resource "aws_iam_policy" "environment_secrets_kms_key_usage_policy" {
  name        = "CodaMetrixDataCentral-${var.environment}-secrets_kms_key_usage_policy"
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
      "Resource": "${aws_kms_key.environment_secrets_kms_key.arn}",
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

#######################################
# RDS enhanced monitoring role / policy
#######################################
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "CodaMetrixDataCentral-${var.environment}-rds-enhanced-monitoring"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = data.aws_iam_policy.AmazonRDSEnhancedMonitoringRole.arn
}

############################################
#  VPC flow log role
############################################
resource "aws_iam_role" "vpc_flow_log_service_role" {
  name = "CMXData-${var.environment}-vpc_flow_log_service_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
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
      Name = "CodaMetrix Data Central - vpc_flow_log_service_role"
      Type = "vpc_flow_log_service_role"
    }
  )
}

resource "aws_iam_role_policy" "vpc_flow_log_service_role_policy" {

  name = "CMXData-${var.environment}-vpc_flow_log_service_role_policy"
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
# CloudWatch Alarm related roles amd policies
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
    resources = [aws_sns_topic.environment_cloudwatch_alarm_push_alerts_topic.arn]

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
  arn    = aws_sns_topic.environment_cloudwatch_alarm_push_alerts_topic.arn
  policy = data.aws_iam_policy_document.cloudwatch_alarm_sns_topic_access_policy_doc.json
}


##################################################
# Dundas role, profile and policy attachments
##################################################
resource "aws_iam_role" "dundas_instance_role" {
  name = var.dundas_instance_role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "Role for Dundas Instance"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central - dundas_instance_role"
      Type = "dundas_instance_role"
    }
  )
}

resource "aws_iam_user" "dundas_ses_user" {
  name = "${var.dundas_ses_identity}-${var.environment}@codametrix.com"
  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central - dundas_ses_user"
      Type = "dundas_ses_user"
    }
  )
}

resource "aws_iam_policy" "dundas_secrets_policy" {
  name        = "CodaMetrixDataCentral-${var.environment}-dundas_secrets_policy"
  path        = "/"
  description = "Gives Access to Dundas Secrets"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:CreateSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:ListSecrets",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:CodaMetrixDataCentral/Dundas/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "dundas_kms_key_usage_policy" {
  name        = "CodaMetrixDataCentral-${var.environment}-dundas_database_kms_key_usage_policy"
  path        = var.iam_resource_path
  description = "This policy gives access to the key used for encrypting dundas databases"

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
      "Resource": [
        "${aws_kms_alias.dundas_application_database_kms_key_alias.target_key_arn}",
        "${aws_kms_alias.dundas_warehouse_database_kms_key_alias.target_key_arn}",
        "${aws_kms_alias.dundas_secrets_kms_key_alias.target_key_arn}",
        "${aws_kms_alias.dundas_bucket_kms_key_alias.target_key_arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "dundas_config_bucket_policy" {
  name        = "CodaMetrixDataCentral-${var.environment}-dundas_config_bucket_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": [
          "${aws_s3_bucket.environment_configuration_bucket.arn}",
          "${aws_s3_bucket.environment_configuration_bucket.arn}/*"
        ]
      }
    ]
}
EOF
}


resource "aws_iam_policy" "dundas_instance_tags_policy" {
  name        = "CodaMetrixDataCentral-${var.environment}-dundas_instance_tags_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": "ec2:DescribeTags"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "dundas_instance_email_policy" {
  name        = "CodaMetrixDataCentral-${var.environment}-dundas_instance_email_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": "ses:SendRawEmail",
          "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dundas_secrets_role_policy_attachment" {
  role       = aws_iam_role.dundas_instance_role.name
  policy_arn = aws_iam_policy.dundas_secrets_policy.arn
}

resource "aws_iam_instance_profile" "dundas_instance_profile" {
  name = "${var.dundas_instance_role}-profile"
  role = aws_iam_role.dundas_instance_role.name
}

resource "aws_iam_role_policy_attachment" "dundas_instance_tags_policy_attachment" {
  role       = aws_iam_role.dundas_instance_role.name
  policy_arn = aws_iam_policy.dundas_instance_tags_policy.arn
}

resource "aws_iam_role_policy_attachment" "dundas_kms_key_usage_policy_attachment" {
  role       = aws_iam_role.dundas_instance_role.name
  policy_arn = aws_iam_policy.dundas_kms_key_usage_policy.arn
}

resource "aws_iam_role_policy_attachment" "dundas_config_bucket_policy_attachment" {
  role       = aws_iam_role.dundas_instance_role.name
  policy_arn = aws_iam_policy.dundas_config_bucket_policy.arn
}

resource "aws_iam_user_policy_attachment" "dundas_user_email_policy_attachment" {
  user       = aws_iam_user.dundas_ses_user.name
  policy_arn = aws_iam_policy.dundas_instance_email_policy.arn
}
