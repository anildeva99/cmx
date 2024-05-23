provider "aws" {
  alias = "src"
  region = var.aws_src_region
}

provider "aws" {
  alias = "dst"
  region = var.aws_dst_region
}

data "aws_caller_identity" "current" {
  provider = aws.src
}

data "aws_iam_policy_document" "aws_backup_kms_key_policy" {
  provider  = aws.src
  policy_id = "cmx-${var.environment}-aws-backup-kms-key-policy"

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
    sid     = "AWS Backup encrypt permission"
    actions = ["kms:GenerateDataKey*", "kms:Encrypt", "kms:Decrypt"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "aws_backup_src_region_kms_key" {
  provider                = aws.src
  description             = "Key for encrypting AWS backup, backups"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation
  policy                  = data.aws_iam_policy_document.aws_backup_kms_key_policy.json

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "aws-backup-kms-key"
      Name = "cmx-${var.environment}-aws-backup-kms-key"
    }
  )
}

resource "aws_kms_alias" "aws_backup_src_region_kms_key_alias" {
  provider      = aws.src
  name          = "alias/cmx-${var.environment}-aws-backup-kms-key"
  target_key_id = aws_kms_key.aws_backup_src_region_kms_key.key_id
}

resource "aws_kms_key" "aws_backup_dst_region_kms_key" {
  provider                = aws.dst
  description             = "Key for encrypting AWS backup, backups"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation
  policy                  = data.aws_iam_policy_document.aws_backup_kms_key_policy.json

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "aws-backup-kms-key"
      Name = "cmx-${var.environment}-aws-backup-kms-key"
    }
  )
}

resource "aws_kms_alias" "aws_backup_dst_region_kms_key_alias" {
  provider      = aws.dst
  name          = "alias/cmx-${var.environment}-aws-backup-kms-key"
  target_key_id = aws_kms_key.aws_backup_dst_region_kms_key.key_id
}

resource "aws_backup_vault" "backup_vault_src_region" {
  provider    = aws.src
  name        = "cmx-${var.environment}-aws-backup-vault"
  kms_key_arn = aws_kms_key.aws_backup_src_region_kms_key.arn
  tags = merge(
    var.shared_resource_tags,
    {
      Type = "aws-backup-vault"
      Name = "cmx-${var.environment}-aws-backup-vault"
    }
  )
}

resource "aws_backup_vault" "backup_vault_dst_region" {
  provider    = aws.dst
  name        = "cmx-${var.environment}-aws-backup-vault"
  kms_key_arn = aws_kms_key.aws_backup_dst_region_kms_key.arn
  tags = merge(
    var.shared_resource_tags,
    {
      Type = "aws-backup-vault"
      Name = "cmx-${var.environment}-aws-backup-vault"
    }
  )
}
