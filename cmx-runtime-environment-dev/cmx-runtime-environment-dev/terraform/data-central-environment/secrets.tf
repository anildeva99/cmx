
#################
# Dundas Secrets
#################
resource "aws_secretsmanager_secret" "dundas_config_secret" {
  name = var.dundas_config_secret_name
  description = "Dundas Config for the '${var.environment}' dundas environment."
  kms_key_id = aws_kms_key.dundas_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_config_secret"
      Name = "CodaMetrix Data Central SecretsManager - dundas_config_secret"
    }
  )
}

resource "aws_secretsmanager_secret" "dundas_ses_secret" {
  name = "CodaMetrixDataCentral/Dundas/SES/${var.environment}-${var.dundas_ses_identity}"
  description = "Dundas SES for the '${var.environment}' dundas environment."
  kms_key_id = aws_kms_key.dundas_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_ses_secret"
      Name = "CodaMetrix Data Central SecretsManager - dundas_ses_secret"
    }
  )
}

resource "aws_secretsmanager_secret" "dundas_application_database_secret" {
  name                    = "CodaMetrixDataCentral/Dundas/ApplicationDatabase/${var.environment}-${var.dundas_application_database_username}"
  description             = "Dundas Application Database credentials for Dundas in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.dundas_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type    = "dundas_application_database_secret"
      Name    = "CodaMetrix Data Central SecretsManager - dundas_application_database_secret"
    }
  )
}

resource "aws_secretsmanager_secret" "dundas_warehouse_database_secret" {
  name                    = "CodaMetrixDataCentral/Dundas/WarehouseDatabase/${var.environment}-${var.dundas_application_database_username}"
  description             = "Dundas warehouse Database credentials for Dundas in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.dundas_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type    = "dundas_warehouse_database_secret"
      Name    = "CodaMetrix Data Central SecretsManager - dundas_warehouse_database_secret"
    }
  )
}

resource "aws_secretsmanager_secret" "dundas_application_database_admin_secret" {
  name                    = "CodaMetrixDataCentral/Dundas/ApplicationDatabase/${var.environment}-${var.dundas_application_database_admin_username}"
  description             = "Admin Database credentials for Dundas application database in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.dundas_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type    = "dundas_application_database_admin_secret"
      Name    = "CodaMetrix Data Central SecretsManager - dundas_application_database_admin_secret"
    }
  )
}

resource "aws_secretsmanager_secret" "dundas_warehouse_database_admin_secret" {
  name                    = "CodaMetrixDataCentral/Dundas/WarehouseDatabase/${var.environment}-${var.dundas_warehouse_database_admin_username}"
  description             = "Admin Database credentials for Dundas warehouse in the '${var.environment}' environment."
  kms_key_id              = aws_kms_key.dundas_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type    = "dundas_warehouse_database_admin_secret"
      Name    = "CodaMetrix Data Central SecretsManager - dundas_warehouse_database_admin_secret"
    }
  )
}
