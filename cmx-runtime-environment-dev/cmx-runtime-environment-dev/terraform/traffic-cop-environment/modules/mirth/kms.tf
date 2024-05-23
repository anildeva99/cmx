# Encryption key for mirth RDS database
resource "aws_kms_key" "mirth_database_kms_key" {
  description             = "Key for encrypting the mirth database"
  deletion_window_in_days = 30

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "mirth_database_kms_key"
      Name = "CodaMetrix Traffic Cop KMS - mirth_database_kms_key"
    }
  )
}

resource "aws_kms_alias" "mirth_database_kms_key_alias" {
  name          = var.mirth_database_kms_key_alias
  target_key_id = aws_kms_key.mirth_database_kms_key.key_id
}
