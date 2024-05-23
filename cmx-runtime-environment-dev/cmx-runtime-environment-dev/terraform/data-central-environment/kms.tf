
##############
# Dundas Keys
##############
# Encryption key for dundas secrets
resource "aws_kms_key" "dundas_secrets_kms_key" {
  description             = "Key for encrypting the dundas secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_secrets_kms_key"
      Name = "CodaMetrix Data Central KMS - dundas_secrets_kms_key"
    }
  )
}

resource "aws_kms_alias" "dundas_secrets_kms_key_alias" {
  name          = var.dundas_secrets_kms_key_alias
  target_key_id = aws_kms_key.dundas_secrets_kms_key.key_id
}

# Encryption key for the Dundas application RDS database
resource "aws_kms_key" "dundas_application_database_kms_key" {
  description             = "Key for encrypting the dundas application database"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_application_database_kms_key"
      Name = "CodaMetrix Data Central KMS - dundas_application_database_kms_key"
    }
  )
}

resource "aws_kms_alias" "dundas_application_database_kms_key_alias" {
  name          = "alias/CodaMetrixDataCentral-${var.environment}-dundas_application_database_key"
  target_key_id = aws_kms_key.dundas_application_database_kms_key.key_id
}

# Encryption key for warehouse RDS database
resource "aws_kms_key" "dundas_warehouse_database_kms_key" {
  description             = "Key for encrypting the dundas warehouse database"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_warehouse_database_kms_key"
      Name = "CodaMetrix Data Central KMS - dundas_warehouse_database_kms_key"
    }
  )
}

resource "aws_kms_alias" "dundas_warehouse_database_kms_key_alias" {
  name          = "alias/CodaMetrixDataCentral-${var.environment}-dundas_warehouse_database_key"
  target_key_id = aws_kms_key.dundas_warehouse_database_kms_key.key_id
}

# Encryption key for warehouse RDS database
resource "aws_kms_key" "dundas_bucket_kms_key" {
  description             = "Key for encrypting the dundas config bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_bucket_kms_key"
      Name = "CodaMetrix Data Central KMS - dundas_bucket_kms_key"
    }
  )
}

resource "aws_kms_alias" "dundas_bucket_kms_key_alias" {
  name          = "alias/CodaMetrixDataCentral-${var.environment}-dundas_bucket_kms_key"
  target_key_id = aws_kms_key.dundas_bucket_kms_key.key_id
}

# Encryption key for environment secrets
resource "aws_kms_key" "environment_secrets_kms_key" {
  description             = "Key for encrypting the environment secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_secrets_kms_key"
      Name = "CodaMetrix Data Central KMS - environment_secrets_kms_key"
    }
  )
}

resource "aws_kms_alias" "environment_secrets_kms_key_alias" {
  name          = var.environment_secrets_kms_key_alias
  target_key_id = aws_kms_key.environment_secrets_kms_key.key_id
}
