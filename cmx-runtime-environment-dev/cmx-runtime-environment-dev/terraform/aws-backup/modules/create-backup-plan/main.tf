provider "aws" {
  alias  = "src"
  region = var.aws_src_region
}

provider "aws" {
  alias  = "dst"
  region = var.aws_dst_region
}

resource "aws_backup_plan" "environment_backup_plan" {
  provider = aws.src
  name     = "cmx-${var.environment}-aws-backup-plan"

  # Daily rule, delete after 30 days
  rule {
    rule_name         = "cmx-${var.environment}-backup-rule-daily"
    target_vault_name = var.src_region_vault_name
    schedule          = "cron(0 0 * * ? *)"
    lifecycle {
      delete_after = 30
    }
    recovery_point_tags = merge(
      var.shared_resource_tags,
      {
        Type = "aws-backup-recovery-point-daily"
      }
    )
    copy_action {
      destination_vault_arn = var.dst_region_vault_arn
      lifecycle {
        delete_after = 30
      }
    }
  }

  # Weekly rule, delete after 60 days
  rule {
    rule_name         = "cmx-${var.environment}-backup-rule-weekly"
    target_vault_name = var.src_region_vault_name
    schedule          = "cron(0 0 ? * FRI *)"
    lifecycle {
      delete_after = 60
    }
    recovery_point_tags = merge(
      var.shared_resource_tags,
      {
        Type = "aws-backup-recovery-point-weekly"
      }
    )
    copy_action {
      destination_vault_arn = var.dst_region_vault_arn
      lifecycle {
        delete_after = 60
      }
    }
  }

  # Monthly rule, delete after 1 year
  rule {
    rule_name         = "cmx-${var.environment}-backup-rule-monthly"
    target_vault_name = var.src_region_vault_name
    schedule          = "cron(0 0 30 * ? *)"
    lifecycle {
      cold_storage_after = 1
      delete_after       = 365
    }
    recovery_point_tags = merge(
      var.shared_resource_tags,
      {
        Type = "aws-backup-recovery-point-monthly"
      }
    )
    copy_action {
      destination_vault_arn = var.dst_region_vault_arn
      lifecycle {
        cold_storage_after = 1
        delete_after       = 365
      }
    }
  }

  # Yearly rule, delete after 7 year
  rule {
    rule_name         = "cmx-${var.environment}-backup-rule-monthly"
    target_vault_name = var.src_region_vault_name
    schedule          = "cron(0 0 30 * ? *)"
    lifecycle {
      cold_storage_after = 1
      delete_after       = 2555
    }
    recovery_point_tags = merge(
      var.shared_resource_tags,
      {
        Type = "aws-backup-recovery-point-yearly"
      }
    )
    copy_action {
      destination_vault_arn = var.dst_region_vault_arn
      lifecycle {
        cold_storage_after = 1
        delete_after       = 2555
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "aws-backup-plan"
      Name = "cmx-${var.environment}-aws-backup-plan"
    }
  )

}

resource "aws_iam_role" "aws_backup_role" {
  provider           = aws.src
  name               = "cmx-${var.environment}-aws-backup-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws_backup_policy_attachment" {
  provider   = aws.src
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.aws_backup_role.name
}

resource "aws_backup_selection" "environment_backup_selection" {
  provider     = aws.src
  iam_role_arn = aws_iam_role.aws_backup_role.arn
  name         = "cmx-${var.environment}-aws-backup-selection"
  plan_id      = aws_backup_plan.environment_backup_plan.id

  resources = var.target_resources_arns
}
