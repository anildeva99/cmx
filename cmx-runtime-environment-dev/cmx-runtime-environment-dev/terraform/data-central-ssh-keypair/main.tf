###############################################################################################
provider "aws" {
  region = var.aws_region
}

resource "aws_kms_key" "environment_keypair_secrets_kms_key" {
  description             = "Key for encrypting the environment keypair secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_keypair_secrets_kms_key"
      Name = "CodaMetrix Application KMS - environment_keypair_secrets_kms_key"
    }
  )
}

resource "aws_secretsmanager_secret" "environment_bastion_host_ubuntu_private_key_secret" {
  name                    = var.aws_secret_bastion_host_ubuntu_private_key
  description             = "Cluster Bastion keypair for ubuntu in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.environment_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_bastion_host_ubuntu_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - environment_bastion_host_ubuntu_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "environment_bastion_host_ubuntu_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.environment_bastion_host_ubuntu_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "environment_bastion_host_ubuntu_public_key_secret" {
  name                    = "${var.aws_secret_bastion_host_ubuntu_private_key}.pub"
  description             = "Cluster Bastion keypair for ubuntu in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.environment_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_bastion_host_ubuntu_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - environment_bastion_host_ubuntu_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "environment_bastion_host_ubuntu_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.environment_bastion_host_ubuntu_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

#####################################################################################################
resource "aws_secretsmanager_secret" "environment_bastion_host_bastion_private_key_secret" {
  name                    = var.aws_secret_bastion_host_bastion_private_key
  description             = "Bastion host keypair for 'bastion' user in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.environment_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_bastion_host_bastion_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - environment_bastion_host_bastion_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "environment_bastion_host_bastion_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.environment_bastion_host_bastion_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "environment_bastion_host_bastion_public_key_secret" {
  name                    = "${var.aws_secret_bastion_host_bastion_private_key}.pub"
  description             = "Bastion host keypair for bastion user in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.environment_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_bastion_host_bastion_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - environment_bastion_host_bastion_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "environment_bastion_host_bastion_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.environment_bastion_host_bastion_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

#####################################################################################################
resource "aws_secretsmanager_secret" "environment_dundas_private_key_secret" {
  name                    = var.aws_secret_dundas_private_key
  description             = "Dundas keypair for bastion user in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.environment_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_dundas_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - environment_dundas_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "environment_dundas_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.environment_dundas_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "environment_dundas_public_key_secret" {
  name                    = "${var.aws_secret_dundas_private_key}.pub"
  description             = "Dundas keypair for bastion user in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.environment_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_dundas_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - environment_dundas_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "environment_dundas_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.environment_dundas_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}
