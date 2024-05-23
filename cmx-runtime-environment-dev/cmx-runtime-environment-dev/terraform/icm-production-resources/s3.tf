resource "aws_s3_bucket" "icm_cold_storage_archive_bucket" {
  bucket        = "icm-cold-storage-archive.${var.environment}.ps.codametrix.com"
  region        = var.aws_region
  force_destroy = false

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_alias.icm_cold_storage_archive_key_alias.target_key_id
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "ICM Production Resources - icm_cold_storage_archive_bucket",
      Type = "icm_cold_storage_archive_bucket",
    }
  )
}

resource "aws_s3_bucket" "pdr_cold_storage_archive_bucket" {
  bucket        = "pdr-cold-storage-archive.${var.environment}.ps.codametrix.com"
  region        = var.aws_region
  force_destroy = false

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_alias.pdr_cold_storage_archive_key_alias.target_key_id
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "ICM Production Resources - pdr_cold_storage_archive_bucket",
      Type = "pdr_cold_storage_archive_bucket",
    }
  )
}
