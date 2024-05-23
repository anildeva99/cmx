######################
# AWS Managed Policies
######################
data "aws_iam_policy" "AmazonRDSEnhancedMonitoringRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
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

resource "aws_iam_policy" "mirth_database_secrets_usage_policy" {
  name        = var.mirth_database_secrets_usage_policy_name
  path        = var.iam_resource_path
  description = "This policy gives access to all mirth database secrets"

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
        ${join(", ", formatlist(local.json_list_item, aws_secretsmanager_secret.mirth_database_secret.*.arn))}
      ]
    }
  ]
}
POLICY
}

###################################################
# Mirth container roles / policy attachments
###################################################
resource "aws_iam_role" "mirth_role" {
  name = var.mirth_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  path        = var.iam_resource_path
  description = "This role gives Mirth containers access to AWS resources"

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Traffic Cop IAM - mirth_role"
      Type     = "mirth_role"
      RoleName = var.mirth_role_name
    }
  )
}

# Enable Mirth to read/write the temp bucket
resource "aws_iam_role_policy_attachment" "mirth_role_temp_bucket_policy_attachment" {
  role       = aws_iam_role.mirth_role.name
  policy_arn = var.temp_bucket_usage_policy_arn
}

resource "aws_iam_role_policy_attachment" "mirth_instance_ecr_policy_attachment" {
  role       = aws_iam_role.mirth_role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}

resource "aws_iam_instance_profile" "mirth_instance_profile" {
  name = var.mirth_role_name
  role = aws_iam_role.mirth_role.name
}

#######################################
# RDS enhanced monitoring role / policy
#######################################
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = var.mirth_rds_enhanced_monitoring_role_name
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = data.aws_iam_policy.AmazonRDSEnhancedMonitoringRole.arn
}
