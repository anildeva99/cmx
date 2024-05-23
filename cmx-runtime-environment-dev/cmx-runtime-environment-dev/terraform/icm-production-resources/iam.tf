#####################################################
# Look up the MFA policy so we can assign it to users
#####################################################
data "aws_iam_policy" "mfa_policy" {
  arn = var.mfa_policy_arn
}

locals {
  user_name_template = "$${user_email}"
}

data "template_file" "icm_production_user_names" {
  count    = length(var.icm_production_users)
  template = local.user_name_template
  vars = {
    user_email = "${lookup(var.icm_production_user_email_map, element(var.icm_production_users, count.index))}"
  }
}

data "template_file" "cold_archive_user_names" {
  count    = length(var.cold_archive_users)
  template = local.user_name_template
  vars = {
    user_email = "${lookup(var.icm_production_user_email_map, element(var.cold_archive_users, count.index))}"
  }
}

data "template_file" "schema_bucket_user_names" {
  count    = length(var.schema_bucket_users)
  template = local.user_name_template
  vars = {
    user_email = "${lookup(var.icm_production_user_email_map, element(var.schema_bucket_users, count.index))}"
  }
}

resource "aws_iam_policy" "icm_production_users_manage_access_key_policy" {
  name        = "ICMProductionResources-${var.environment}-icm_production_users_manage_access_key_policy"
  path        = var.iam_resource_path
  description = "ICM Production resource access policy, enabling access key management"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateAccessKey",
                "iam:GetUser",
                "iam:ListAccessKeys"
            ],
            "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "icm_production_users_misc_policy" {
  name        = "ICMProductionResources-${var.environment}-icm_production_users_misc_policy"
  path        = var.iam_resource_path
  description = "ICM Production resource access policy for miscellaneous tasks"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "icm_cold_storage_archive_bucket_fullaccess_policy" {
  name        = "ICMProductionResources-${var.environment}-icm_cold_storage_archive_bucket_fullaccess_policy"
  path        = var.iam_resource_path
  description = "ICM Production resource access policy for ${aws_s3_bucket.icm_cold_storage_archive_bucket.id}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.icm_cold_storage_archive_bucket.arn}",
        "${aws_s3_bucket.icm_cold_storage_archive_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "icm_cold_storage_archive_key_fullaccess_policy" {
  name        = "ICMProductionResources-${var.environment}-icm_cold_storage_archive_key_fullaccess_policy"
  path        = var.iam_resource_path
  description = "ICM Production resource access policy for ${aws_kms_alias.icm_cold_storage_archive_key_alias.name}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:GenerateDataKey*",
        "kms:Encrypt",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_kms_key.icm_cold_storage_archive_key.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "pdr_cold_storage_archive_bucket_fullaccess_policy" {
  name        = "ICMProductionResources-${var.environment}-pdr_cold_storage_archive_bucket_fullaccess_policy"
  path        = var.iam_resource_path
  description = "ICM Production resource access policy for ${aws_s3_bucket.pdr_cold_storage_archive_bucket.id}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.pdr_cold_storage_archive_bucket.arn}",
        "${aws_s3_bucket.pdr_cold_storage_archive_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "pdr_cold_storage_archive_key_fullaccess_policy" {
  name        = "ICMProductionResources-${var.environment}-pdr_cold_storage_archive_key_fullaccess_policy"
  path        = var.iam_resource_path
  description = "ICM Production resource access policy for ${aws_kms_alias.pdr_cold_storage_archive_key_alias.name}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:GenerateDataKey*",
        "kms:Encrypt",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_kms_key.pdr_cold_storage_archive_key.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "schema_bucket_fullaccess_policy" {
  name        = "ICMProductionResources-${var.environment}-schema_bucket_fullaccess_policy"
  path        = var.iam_resource_path
  description = "ICM Production resource access policy for ${var.schema_bucket_arn}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.schema_bucket_arn}",
        "${var.schema_bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

##########################
# ICM Production Users and Attachments
##########################
resource "aws_iam_user" "icm_production_users" {
  count = length(var.icm_production_users)
  name  = element(data.template_file.icm_production_user_names.*.rendered, count.index)

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "ICM Production Resources - icm_production_users - ${element(data.template_file.icm_production_user_names.*.rendered, count.index)}"
      Type     = "icm_production_users"
      UserName = element(data.template_file.icm_production_user_names.*.rendered, count.index)
      FullName = element(var.icm_production_users, count.index)
    }
  )
}

resource "aws_iam_group" "icm_production_users" {
  name = "ICMProductionResources-${var.environment}-icm_production_users"
  path = var.iam_resource_path
}

resource "aws_iam_group_membership" "icm_production_users_membership" {
  name  = "ICMProductionResources-${var.environment}-icm_production_users_membership"
  users = aws_iam_user.icm_production_users.*.name
  group = aws_iam_group.icm_production_users.name
}

resource "aws_iam_group_policy_attachment" "icm_production_users_manage_access_key_policy_attachment" {
  group      = aws_iam_group.icm_production_users.name
  policy_arn = aws_iam_policy.icm_production_users_manage_access_key_policy.arn
}

resource "aws_iam_group_policy_attachment" "icm_production_users_group_misc_policy_attachment" {
  group      = aws_iam_group.icm_production_users.name
  policy_arn = aws_iam_policy.icm_production_users_misc_policy.arn
}

resource "aws_iam_group_policy_attachment" "icm_production_users_group_mfa_policy_attachment" {
  group      = aws_iam_group.icm_production_users.name
  policy_arn = data.aws_iam_policy.mfa_policy.arn
}

resource "aws_iam_group" "cold_archive_users" {
  name = "ICMProductionResources-${var.environment}-cold_archive_users"
  path = var.iam_resource_path
}

resource "aws_iam_group_membership" "cold_archive_users_membership" {
  name  = "ICMProductionResources-${var.environment}-cold_archive_users_membership"
  users = data.template_file.cold_archive_user_names.*.rendered
  group = aws_iam_group.cold_archive_users.name
}

resource "aws_iam_group_policy_attachment" "cold_archive_users_group_cold_storage_archive_bucket_policy_attachment" {
  group      = aws_iam_group.cold_archive_users.name
  policy_arn = aws_iam_policy.icm_cold_storage_archive_bucket_fullaccess_policy.arn
}

resource "aws_iam_group_policy_attachment" "cold_archive_users_group_cold_storage_archive_key_policy_attachment" {
  group      = aws_iam_group.cold_archive_users.name
  policy_arn = aws_iam_policy.icm_cold_storage_archive_key_fullaccess_policy.arn
}

resource "aws_iam_group_policy_attachment" "cold_archive_users_group_pdr_cold_storage_archive_bucket_policy_attachment" {
  group      = aws_iam_group.cold_archive_users.name
  policy_arn = aws_iam_policy.pdr_cold_storage_archive_bucket_fullaccess_policy.arn
}

resource "aws_iam_group_policy_attachment" "cold_archive_users_group_pdr_cold_storage_archive_key_policy_attachment" {
  group      = aws_iam_group.cold_archive_users.name
  policy_arn = aws_iam_policy.pdr_cold_storage_archive_key_fullaccess_policy.arn
}

resource "aws_iam_group" "schema_bucket_users" {
  name = "ICMProductionResources-${var.environment}-schema_bucket_users"
  path = var.iam_resource_path
}

resource "aws_iam_group_membership" "schema_bucket_users_membership" {
  name  = "ICMProductionResources-${var.environment}-schema_bucket_users_membership"
  users = data.template_file.schema_bucket_user_names.*.rendered
  group = aws_iam_group.schema_bucket_users.name
}

resource "aws_iam_group_policy_attachment" "schema_bucket_users_group_schema_bucket_policy_attachment" {
  group      = aws_iam_group.schema_bucket_users.name
  policy_arn = aws_iam_policy.schema_bucket_fullaccess_policy.arn
}
