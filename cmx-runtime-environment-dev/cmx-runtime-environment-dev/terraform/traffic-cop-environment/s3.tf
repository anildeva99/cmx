resource "aws_s3_bucket" "configuration_bucket" {
  bucket = "configuration.${var.environment}.tc.codametrix.com"
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

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "configuration_bucket"
      Name = "CodaMetrix Traffic Cop S3 - configuration_bucket"
    }
  )
}

resource "aws_s3_bucket" "mirth_temp_bucket" {
  bucket = "mirth-temp.${var.environment}.tc.codametrix.com"

  depends_on = [
    aws_s3_bucket.logs_bucket,
  ]

  logging {
    target_bucket = var.logs_bucket
    target_prefix = "s3/mirth-temp.${var.environment}.tc.codametrix.com/"
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
      Type = "mirth_temp_bucket"
      Name = "CodaMetrix Traffic Cop S3 - mirth_temp_bucket"
    }
  )
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket        = var.logs_bucket
  force_destroy = true
  acl           = "log-delivery-write"

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
      Type = "logs_bucket"
      Name = "CodaMetrix Traffic Cop S3 - logs_bucket"
    }
  )
}

resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
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
      "Resource": "${aws_s3_bucket.logs_bucket.arn}"
    },
    {
      "Sid": "Get Bucket ACL needed for S3 logging",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.logs_bucket.arn}"
    },
    {
      "Sid": "Put object needed for S3 logging",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.logs_bucket.arn}/*",
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

resource "aws_s3_bucket_public_access_block" "logs_bucket_block_public_access" {
  bucket = aws_s3_bucket.logs_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

########################################################
#  S3 bucket used by ES to store snapshots of indices
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
        kms_master_key_id = aws_kms_alias.elasticsearch_kms_key_alias.target_key_id
      }
    }
  }

  lifecycle_rule {
    id      = "${each.key}_elasticsearch_index_backup_bucket_lifecycle"
    enabled = true

    tags = {
      "rule"      = "elasticsearch_index_backup_bucket"
      "autoclean" = "true"
    }

    transition {
      days          = var.elasticsearch_index_rotation[each.key].s3_bucket_lifecycle_standard_infrequent_access_date
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "${each.key}_elasticsearch_index_backup_bucket"
      Name = "CodaMetrix Traffic Cop S3 - ${each.key}_elasticsearch_index_backup_bucket"
    }
  )
}
