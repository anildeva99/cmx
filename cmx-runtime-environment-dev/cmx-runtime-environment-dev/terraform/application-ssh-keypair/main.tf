###############################################################################################
provider "aws" {
  region = var.aws_region
}

resource "aws_kms_key" "application_keypair_secrets_kms_key" {
  description             = "Key for encrypting the application keypair secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_keypair_secrets_kms_key"
      Name = "CodaMetrix Application KMS -application_keypair_secrets_kms_key"
    }
  )
}

resource "aws_secretsmanager_secret" "application_bastion_host_ubuntu_private_key_secret" {
  name                    = var.aws_secret_bastion_host_ubuntu_private_key
  description             = "Cluster Bastion keypair for ubuntu in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_bastion_host_ubuntu_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_bastion_host_ubuntu_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_bastion_host_ubuntu_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_bastion_host_ubuntu_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "application_bastion_host_ubuntu_public_key_secret" {
  name                    = "${var.aws_secret_bastion_host_ubuntu_private_key}.pub"
  description             = "Cluster Bastion keypair for ubuntu in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_bastion_host_ubuntu_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_bastion_host_ubuntu_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_bastion_host_ubuntu_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_bastion_host_ubuntu_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

###############################################################################################
resource "aws_secretsmanager_secret" "application_customer_vpn_private_key_secret" {
  name                    = var.aws_secret_customer_networking_private_key
  description             = "Keypair for customer vpn in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_customer_vpn_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_customer_vpn_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_customer_vpn_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_customer_vpn_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "application_customer_vpn_public_key_secret" {
  name                    = "${var.aws_secret_customer_networking_private_key}.pub"
  description             = "Keypair for ubuntu of customer VPN in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_customer_vpn_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_customer_vpn_public_key_secret"
    }
  )
}


resource "aws_secretsmanager_secret_version" "application_customer_vpn_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_customer_vpn_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}


#####################################################################################################
resource "aws_secretsmanager_secret" "application_worker_node_ec2_user_private_key_secret" {
  name                    = var.aws_secret_worker_node_private_key
  description             = "Worker node keypair for ec2-user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_worker_node_ec2_user_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_worker_node_ec2_user_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_worker_node_ec2_user_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_worker_node_ec2_user_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "application_worker_node_ec2_user_public_key_secret" {
  name                    = "${var.aws_secret_worker_node_private_key}.pub"
  description             = "Worker node keypair for ec2-user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_worker_node_ec2_user_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_worker_node_ec2_user_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_worker_node_ec2_user_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_worker_node_ec2_user_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

#####################################################################################################
resource "aws_secretsmanager_secret" "application_data_lake_emr_host_ec2_user_private_key_secret" {
  name                    = var.aws_secret_data_lake_emr_host_private_key
  description             = "Data Lake EMR host keypair for ec2-user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_lake_emr_host_ec2_user_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_data_lake_emr_host_ec2_user_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_data_lake_emr_host_ec2_user_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_data_lake_emr_host_ec2_user_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "application_data_lake_emr_host_ec2_user_public_key_secret" {
  name                    = "${var.aws_secret_data_lake_emr_host_private_key}.pub"
  description             = "Data lake EMR host keypair for ec2-user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_lake_emr_host_ec2_user_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_data_lake_emr_host_ec2_user_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_data_lake_emr_host_ec2_user_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_data_lake_emr_host_ec2_user_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

#####################################################################################################
resource "aws_secretsmanager_secret" "application_cluster_bastion_host_bastion_private_key_secret" {
  name                    = var.aws_secret_cluster_bastion_host_private_key
  description             = "Cluster bastion host keypair for bastion user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_cluster_bastion_host_bastion_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_cluster_bastion_host_bastion_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_cluster_bastion_host_bastion_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_cluster_bastion_host_bastion_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "application_cluster_bastion_host_bastion_public_key_secret" {
  name                    = "${var.aws_secret_cluster_bastion_host_private_key}.pub"
  description             = "Cluster bastion host keypair for bastion user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_cluster_bastion_host_bastion_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_cluster_bastion_host_bastion_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_cluster_bastion_host_bastion_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_cluster_bastion_host_bastion_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

#####################################################################################################
resource "aws_secretsmanager_secret" "application_bastion_host_bastion_private_key_secret" {
  name                    = var.aws_secret_bastion_host_bastion_private_key
  description             = "Bastion host keypair for 'bastion' user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_bastion_host_bastion_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_bastion_host_bastion_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_bastion_host_bastion_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_bastion_host_bastion_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "application_bastion_host_bastion_public_key_secret" {
  name                    = "${var.aws_secret_bastion_host_bastion_private_key}.pub"
  description             = "Bastion host keypair for bastion user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_bastion_host_bastion_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - application_bastion_host_bastion_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_bastion_host_bastion_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_bastion_host_bastion_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

#########################
# Ingress Mirth SSH keys
#########################
resource "aws_secretsmanager_secret" "ingress_mirth_ubuntu_private_key_secret" {
  name                    = var.aws_secret_ingress_mirth_ubuntu_private_key
  description             = "Ingress Mirth keypair for 'ubuntu' user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_mirth_ubuntu_private_key_secret"
      Name = "CodaMetrix Application SecretsManager - ingress_mirth_ubuntu_private_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "ingress_mirth_ubuntu_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.ingress_mirth_ubuntu_private_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}

resource "aws_secretsmanager_secret" "ingress_mirth_ubuntu_public_key_secret" {
  name                    = "${var.aws_secret_ingress_mirth_ubuntu_private_key}.pub"
  description             = "Ingress mirth keypair for ubuntu user in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_keypair_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_mirth_ubuntu_public_key_secret"
      Name = "CodaMetrix Application SecretsManager - ingress_mirth_ubuntu_public_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "ingress_mirth_ubuntu_public_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.ingress_mirth_ubuntu_public_key_secret.id
  secret_string = var.aws_secret_manager_secret_key_initial_value
}
