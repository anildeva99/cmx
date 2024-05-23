locals {
  s3_dr_kms_arn_prefix = "arn:aws:kms:${var.dr_region}:${data.aws_caller_identity.current.account_id}:"
}

resource "aws_s3_bucket" "job_data_bucket" {
  bucket = var.job_data_bucket

  depends_on = [
    aws_s3_bucket.application_logs_bucket,
  ]

  logging {
    target_bucket = var.application_logs_bucket
    target_prefix = "s3/${var.job_data_bucket}/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_alias.job_data_bucket_key_alias.target_key_id
      }
    }
  }

  dynamic "replication_configuration" {
    for_each = var.enable_s3_replication ? ["replication"] : []
    content {
      role = aws_iam_role.s3_replication_role.arn

      rules {
        id     = "dr"
        status = "Enabled"

        destination {
          bucket             = "arn:aws:s3:::${replace(var.job_data_bucket, var.environment, var.dr_environment)}"
          storage_class      = "INTELLIGENT_TIERING"
          replica_kms_key_id = "${local.s3_dr_kms_arn_prefix}${replace(aws_kms_alias.job_data_bucket_key_alias.name, var.environment, var.dr_environment)}"
        }

        source_selection_criteria {
          sse_kms_encrypted_objects {
            enabled = true
          }
        }
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "job_data_bucket"
      Name = "CodaMetrix Application S3 - job_data_bucket"
    }
  )
}

resource "aws_s3_bucket" "process_data_bucket" {
  bucket = var.process_data_bucket

  depends_on = [
    aws_s3_bucket.application_logs_bucket,
  ]

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = var.s3_lifecycle_incomplete_upload_days
    enabled                                = true

    noncurrent_version_expiration {
      days = var.s3_lifecycle_old_version_expiration_days
    }

    transition {
      days          = var.s3_lifecycle_intelligent_tiering_days
      storage_class = "INTELLIGENT_TIERING"
    }
  }

  logging {
    target_bucket = var.application_logs_bucket
    target_prefix = "s3/${var.process_data_bucket}/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_alias.process_data_bucket_key_alias.target_key_id
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "process_data_bucket"
      Name = "CodaMetrix Application S3 - process_data_bucket"
    }
  )
}

#########################################
#   S3 bucket used by EMR
#########################################
resource "aws_s3_bucket" "application_data_lake_bucket" {
  bucket = "data-lake.${var.environment}.application.codametrix.com"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.application_data_lake_emr_kms_key.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.application_logs_bucket.bucket
    target_prefix = "s3/data-lake.${var.environment}.application.codametrix.com/"
  }

  versioning {
    enabled = true
  }

  dynamic "replication_configuration" {
    for_each = var.enable_s3_replication ? ["replication"] : []
    content {
      role = aws_iam_role.s3_replication_role.arn

      rules {
        id     = "dr"
        status = "Enabled"

        destination {
          bucket             = "arn:aws:s3:::data-lake.${var.dr_environment}.application.codametrix.com"
          storage_class      = "INTELLIGENT_TIERING"
          replica_kms_key_id = "${local.s3_dr_kms_arn_prefix}${replace(aws_kms_alias.application_data_lake_emr_kms_key_alias.name, var.environment, var.dr_environment)}"
        }

        source_selection_criteria {
          sse_kms_encrypted_objects {
            enabled = true
          }
        }
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_lake_bucket"
      Name = "CodaMetrix Application S3 - application_data_lake_bucket"
    }
  )
}

resource "aws_s3_bucket" "application_data_lake_athena_output_bucket" {
  bucket = "data-lake-athena-temp.${var.environment}.application.codametrix.com"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.athena_output_kms_key.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.application_logs_bucket.bucket
    target_prefix = "s3/data-lake-athena-temp.${var.environment}.application.codametrix.com/"
  }

  versioning {
    enabled = true
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_lake_athena_output_bucket"
      Name = "CodaMetrix Application S3 - application_data_lake_athena_output_bucket"
    }
  )
}

resource "aws_s3_bucket" "application_configuration_bucket" {
  bucket = "configuration.${var.environment}.application.codametrix.com"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  dynamic "replication_configuration" {
    for_each = var.enable_s3_replication ? ["replication"] : []
    content {
      role = aws_iam_role.s3_replication_role.arn

      rules {
        id     = "dr"
        status = "Enabled"

        destination {
          bucket        = "arn:aws:s3:::configuration.${var.dr_environment}.application.codametrix.com"
          storage_class = "INTELLIGENT_TIERING"
        }
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_configuration_bucket"
      Name = "CodaMetrix Application S3 - application_configuration_bucket"
    }
  )
}
########################################################################

resource "aws_s3_bucket" "application_healthsystem_ingest_bucket" {
  for_each      = toset(var.healthsystems)
  bucket        = "ingest.${each.value}.${var.environment}.app.codametrix.com"
  force_destroy = true

  depends_on = [
    aws_s3_bucket.application_logs_bucket,
  ]

  logging {
    target_bucket = var.application_logs_bucket
    target_prefix = "s3/ingest.${each.value}.${var.environment}.app.codametrix.com/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.application_healthsystem_kms_key[each.value].key_id
      }
    }
  }

  dynamic "replication_configuration" {
    for_each = var.enable_s3_replication ? ["replication"] : []
    content {
      role = aws_iam_role.s3_replication_role.arn

      rules {
        id     = "dr"
        status = "Enabled"

        destination {
          bucket             = "arn:aws:s3:::ingest.${each.value}.${var.dr_environment}.app.codametrix.com"
          storage_class      = "INTELLIGENT_TIERING"
          replica_kms_key_id = "${local.s3_dr_kms_arn_prefix}${replace(aws_kms_alias.application_healthsystem_kms_key_alias[each.value].name, var.environment, var.dr_environment)}"
        }

        source_selection_criteria {
          sse_kms_encrypted_objects {
            enabled = true
          }
        }
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type         = "application_healthsystem_ingest_bucket"
      Name         = "CodaMetrix Application S3 - application_healthsystem_ingest_bucket"
      HealthSystem = each.value
    }
  )
}

// Disable encryption requirement, since we're using encryption by default and adding the requirement adds complexity
/*
resource "aws_s3_bucket_policy" "application_healthsystem_ingest_bucket_policy" {
  count         = length(var.healthsystems)
  bucket        = element(aws_s3_bucket.application_healthsystem_ingest_bucket.*.id, count.index)

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
     {
          "Sid": "DenyUnEncryptedObjectUploads",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": "${element(aws_s3_bucket.application_healthsystem_ingest_bucket.*.arn, count.index)}/*",
          "Condition": {
                  "Null": {
                         "s3:x-amz-server-side-encryption": true
                  }
         }
     }
	]
}
POLICY
}
*/

resource "aws_s3_bucket_public_access_block" "application_healthsystem_ingest_bucket_block_public_access" {
  for_each = toset(var.healthsystems)
  bucket   = aws_s3_bucket.application_healthsystem_ingest_bucket[each.value].id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket" "application_tenant_documents_bucket" {
  for_each      = toset(keys(var.tenants))
  bucket        = "documents.${var.tenants[each.value]}.${each.value}.${var.environment}.app.codametrix.com"
  force_destroy = true

  depends_on = [
    aws_s3_bucket.application_logs_bucket,
  ]

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = var.s3_lifecycle_incomplete_upload_days
    enabled                                = true

    transition {
      days          = var.s3_lifecycle_intelligent_tiering_days
      storage_class = "INTELLIGENT_TIERING"
    }
  }

  logging {
    target_bucket = var.application_logs_bucket
    target_prefix = "s3/documents.${var.tenants[each.value]}.${each.value}.${var.environment}.app.codametrix.com/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.application_healthsystem_kms_key[var.tenants[each.value]].key_id
      }
    }
  }

  dynamic "replication_configuration" {
    for_each = var.enable_s3_replication ? ["replication"] : []
    content {
      role = aws_iam_role.s3_replication_role.arn

      rules {
        id     = "dr"
        status = "Enabled"

        destination {
          bucket             = "arn:aws:s3:::documents.${var.tenants[each.value]}.${each.value}.${var.dr_environment}.app.codametrix.com"
          storage_class      = "INTELLIGENT_TIERING"
          replica_kms_key_id = "${local.s3_dr_kms_arn_prefix}${replace(aws_kms_alias.application_healthsystem_kms_key_alias[var.tenants[each.value]].name, var.environment, var.dr_environment)}"
        }

        source_selection_criteria {
          sse_kms_encrypted_objects {
            enabled = true
          }
        }
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type         = "application_tenant_documents_bucket"
      Name         = "CodaMetrix Application S3 - application_tenant_documents_bucket"
      Tenant       = each.value
      HealthSystem = var.tenants[each.value]
    }
  )
}

resource "aws_s3_bucket" "mirth_temp_bucket" {
  bucket = "mirth-temp.${var.environment}.application.codametrix.com"

  depends_on = [
    aws_s3_bucket.application_logs_bucket,
  ]

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = var.s3_lifecycle_incomplete_upload_days
    enabled                                = true

    noncurrent_version_expiration {
      days = var.s3_lifecycle_old_version_expiration_days
    }

    transition {
      days          = var.s3_lifecycle_intelligent_tiering_days
      storage_class = "INTELLIGENT_TIERING"
    }
  }

  logging {
    target_bucket = var.application_logs_bucket
    target_prefix = "s3/mirth-temp.${var.environment}.application.codametrix.com/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  dynamic "replication_configuration" {
    for_each = var.enable_s3_replication ? ["replication"] : []
    content {
      role = aws_iam_role.s3_replication_role.arn

      rules {
        id     = "dr"
        status = "Enabled"

        destination {
          bucket             = "arn:aws:s3:::mirth-temp.${var.dr_environment}.application.codametrix.com"
          storage_class      = "INTELLIGENT_TIERING"
          replica_kms_key_id = "${local.s3_dr_kms_arn_prefix}alias/aws/s3"
        }

        source_selection_criteria {
          sse_kms_encrypted_objects {
            enabled = true
          }
        }
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "mirth_temp_bucket"
      Name = "CodaMetrix Application S3 - mirth_temp_bucket"
    }
  )
}

// Disable encryption requirement, since we're using encryption by default and adding the requirement adds complexity
/*
resource "aws_s3_bucket_policy" "application_tenant_documents_bucket_policy" {
  count         = length(var.tenants)
  bucket        = "${element(aws_s3_bucket.application_tenant_documents_bucket.*.id, count.index)}"

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
     {
          "Sid": "DenyUnEncryptedObjectUploads",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": "${element(aws_s3_bucket.application_tenant_documents_bucket.*.arn, count.index)}/*",
          "Condition": {
                  "Null": {
                         "s3:x-amz-server-side-encryption": true
                  }
         }
     }
	]
}
POLICY
}
*/

resource "aws_s3_bucket_public_access_block" "application_tenant_documents_bucket_block_public_access" {
  for_each = toset(keys(var.tenants))
  bucket   = aws_s3_bucket.application_tenant_documents_bucket[each.value].id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket" "application_logs_bucket" {
  bucket        = var.application_logs_bucket
  force_destroy = true
  acl           = "log-delivery-write"

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = var.s3_lifecycle_incomplete_upload_days
    enabled                                = true

    expiration {
      days = var.s3_lifecycle_logs_expiration_days
    }

    noncurrent_version_expiration {
      days = var.s3_lifecycle_old_version_expiration_days
    }

    transition {
      days          = var.s3_lifecycle_intelligent_tiering_days
      storage_class = "INTELLIGENT_TIERING"
    }
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_logs_bucket"
      Name = "CodaMetrix Application S3 - application_logs_bucket"
    }
  )
}

resource "aws_s3_bucket_policy" "application_logs_bucket_policy" {
  bucket = aws_s3_bucket.application_logs_bucket.id

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Put bucket policy needed for Redshift audit logging",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::${var.application_data_warehouse_log_bucket_policy_aws_account}:user/logs"
			},
			"Action": [
        "s3:Get*",
        "s3:Put*"
      ],
			"Resource": "${aws_s3_bucket.application_logs_bucket.arn}/*"
		},
		{
			"Sid": "Get bucket policy needed for Redshift audit logging ",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::${var.application_data_warehouse_log_bucket_policy_aws_account}:user/logs"
			},
			"Action": "s3:GetBucketAcl",
			"Resource": "${aws_s3_bucket.application_logs_bucket.arn}"
		},
    {
      "Sid": "Get Bucket ACL needed for S3 logging",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": [
        "s3:GetBucketAcl",
        "s3:PutBucketAcl"
      ],
      "Resource": "${aws_s3_bucket.application_logs_bucket.arn}"
    },
    {
      "Sid": "Get Bucket ACL needed for S3 logging",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.application_logs_bucket.arn}"
    },
    {
      "Sid": "Put object needed for S3 logging",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.application_logs_bucket.arn}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
	]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "application_logs_bucket_block_public_access" {
  bucket = aws_s3_bucket.application_logs_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

/*
resource "aws_s3_bucket" "application_static_bucket" {
  bucket = "static.${var.environment}.app.codametrix.com"
  acl    = "public-read"

  depends_on = [
    aws_s3_bucket.application_logs_bucket,
  ]

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "DELETE"]
    allowed_origins = ["https://${var.application_api_dns_address}"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  tags = merge(
		var.shared_resource_tags,
		{
      Type         = "application_static_bucket"
      Name         = "CodaMetrix Application S3 - application_static_bucket"
    }
  )
}

resource "aws_s3_bucket_policy" "application_static_bucket_policy" {
  bucket = "${aws_s3_bucket.application_static_bucket.id}"

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [{
      "Sid": "CloudFrontReadGetObject",
      "Effect": "Allow",
      "Principal": {"CanonicalUser":"${aws_cloudfront_origin_access_identity.application_static_oai.s3_canonical_user_id}"},
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.application_static_bucket.id}/*"
  }]
}
POLICY
}
*/

########################################################
#   S3 bucket used by ES to store snapshots of indices
########################################################
resource "aws_s3_bucket" "elasticsearch_index_backup_bucket" {
  for_each = var.elasticsearch_index_rotation
  bucket   = var.elasticsearch_index_rotation[each.key].bucket

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_alias.application_elasticsearch_kms_key_alias.target_key_id
      }
    }
  }

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = var.s3_lifecycle_incomplete_upload_days
    enabled                                = true
    id                                     = "${each.key}_elasticsearch_index_backup_bucket_lifecycle"

    noncurrent_version_expiration {
      days = var.s3_lifecycle_old_version_expiration_days
    }

    transition {
      days          = var.s3_lifecycle_intelligent_tiering_days
      storage_class = "INTELLIGENT_TIERING"
    }

  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "${each.key}_elasticsearch_index_backup_bucket"
      Name = "CodaMetrix Application S3 - ${each.key}_elasticsearch_index_backup_bucket"
    }
  )
}

resource "aws_vpc_endpoint" "application_s3_vpc_endpoint" {
  vpc_id          = aws_vpc.application_vpc.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.public_route_table.id, aws_route_table.private_route_table.id]

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_s3_vpc_endpoint"
      Name = "CodaMetrix Application S3 - application_s3_vpc_endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "ingress_s3_vpc_endpoint" {
  vpc_id          = aws_vpc.ingress_vpc.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.ingress_public_route_table.id, aws_route_table.ingress_private_route_table.id]

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_s3_vpc_endpoint"
      Name = "CodaMetrix Application S3 - ingress_s3_vpc_endpoint"
    }
  )
}

output "application_logs_bucket_arns" {
  value = aws_s3_bucket.application_logs_bucket.arn
}

/*
output "application_static_bucket_arn" {
  value = aws_s3_bucket.application_static_bucket.arn
}
*/
