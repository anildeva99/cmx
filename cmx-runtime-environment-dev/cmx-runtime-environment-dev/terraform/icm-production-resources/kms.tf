# KMS Key for the ICM Cold Storage bucket
resource "aws_kms_key" "icm_cold_storage_archive_key" {
  description         = "Key for encrypting data in the ICM Cold Storage Archive bucket in ${var.environment}"
  enable_key_rotation = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "ICM Production Resources - icm_cold_storage_archive_key",
      Type = "icm_cold_storage_archive_key",
    }
  )
}

resource "aws_kms_alias" "icm_cold_storage_archive_key_alias" {
  name          = "alias/ICMProductionResources-${var.environment}-icm_cold_storage_archive_key_alias"
  target_key_id = aws_kms_key.icm_cold_storage_archive_key.key_id
}

# KMS Key for the PDR Cold Storage bucket
resource "aws_kms_key" "pdr_cold_storage_archive_key" {
  description         = "Key for encrypting data in the PDR Cold Storage Archive bucket in ${var.environment}"
  enable_key_rotation = var.enable_key_rotation

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "ICM Production Resources - pdr_cold_storage_archive_key",
      Type = "pdr_cold_storage_archive_key",
    }
  )
}

resource "aws_kms_alias" "pdr_cold_storage_archive_key_alias" {
  name          = "alias/ICMProductionResources-${var.environment}-pdr_cold_storage_archive_key_alias"
  target_key_id = aws_kms_key.pdr_cold_storage_archive_key.key_id
}
