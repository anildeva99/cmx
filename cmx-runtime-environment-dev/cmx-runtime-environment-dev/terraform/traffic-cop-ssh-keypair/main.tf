###############################################################################################
provider "aws" {
  region = var.aws_region
}

resource "aws_kms_key" "keypair_secrets_kms_key" {
  description             = "Key for encrypting the keypair secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "keypair_secrets_kms_key"
      Name = "CodaMetrix Traffic Cop KMS -keypair_secrets_kms_key"
    }
  )
}

resource "aws_secretsmanager_secret" "bastion_host_ubuntu_private_key_secret" {
  name                    = var.aws_secret_bastion_host_ubuntu_private_key
  description             = "Cluster Bastion keypair for ubuntu in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "bastion_host_ubuntu_private_key_secret"
      Name = "CodaMetrix Traffic Cop SecretsManager - bastion_host_ubuntu_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "bastion_host_ubuntu_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.bastion_host_ubuntu_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "bastion_host_ubuntu_public_key_secret" {
  name                    = "${var.aws_secret_bastion_host_ubuntu_private_key}.pub"
  description             = "Cluster Bastion keypair for ubuntu in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "bastion_host_ubuntu_public_key_secret"
      Name = "CodaMetrix Traffic Cop SecretsManager - bastion_host_ubuntu_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "bastion_host_ubuntu_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.bastion_host_ubuntu_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

###############################################################################################
resource "aws_secretsmanager_secret" "customerrouter_private_key_secret" {
  name                    = var.aws_secret_customerrouter_private_key
  description             = "Keypair for customer routers in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customerrouter_private_key_secret"
      Name = "CodaMetrix Traffic Cop SecretsManager - customerrouter_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "customerrouter_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.customerrouter_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "customerrouter_public_key_secret" {
  name                    = "${var.aws_secret_customerrouter_private_key}.pub"
  description             = "Keypair for customer routers in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customerrouter_public_key_secret"
      Name = "CodaMetrix Traffic Cop SecretsManager - customerrouter_public_key_secret"
    }
  )
}


resource "aws_secretsmanager_secret_version" "customerrouter_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.customerrouter_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

#####################################################################################################
resource "aws_secretsmanager_secret" "bastion_host_bastion_private_key_secret" {
  name                    = var.aws_secret_bastion_host_bastion_private_key
  description             = "Bastion host keypair for 'bastion' user in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "bastion_host_bastion_private_key_secret"
      Name = "CodaMetrix Traffic Cop SecretsManager - bastion_host_bastion_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "bastion_host_bastion_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.bastion_host_bastion_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "bastion_host_bastion_public_key_secret" {
  name                    = "${var.aws_secret_bastion_host_bastion_private_key}.pub"
  description             = "Bastion host keypair for bastion user in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "bastion_host_bastion_public_key_secret"
      Name = "CodaMetrix Traffic Cop SecretsManager - bastion_host_bastion_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "bastion_host_bastion_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.bastion_host_bastion_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

#########################
# Mirth SSH keys
#########################
resource "aws_secretsmanager_secret" "mirth_ubuntu_private_key_secret" {
  name                    = var.aws_secret_mirth_ubuntu_private_key
  description             = "Mirth keypair for ubuntu user in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "mirth_ubuntu_private_key_secret"
      Name = "CodaMetrix Traffic Cop SecretsManager - mirth_ubuntu_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "mirth_ubuntu_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.mirth_ubuntu_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "mirth_ubuntu_public_key_secret" {
  name                    = "${var.aws_secret_mirth_ubuntu_private_key}.pub"
  description             = "Mirth keypair for ubuntu user in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "mirth_ubuntu_public_key_secret"
      Name = "CodaMetrix Traffic Cop SecretsManager - mirth_ubuntu_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "mirth_ubuntu_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.mirth_ubuntu_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}
