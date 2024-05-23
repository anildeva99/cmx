resource "aws_s3_bucket" "environment_configuration_bucket" {
  bucket = "configuration.${var.environment}.datacentral.codametrix.com"
  acl    = "private"

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
      Type = "environment_configuration_bucket"
      Name = "CodaMetrix Data Central S3 - environment_configuration_bucket"
    }
  )
}

resource "aws_s3_bucket" "environment_logs_bucket" {
  bucket        = var.environment_logs_bucket
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
      Type = "environment_logs_bucket"
      Name = "CodaMetrix Data Central S3 - environment_logs_bucket"
    }
  )
}

resource "aws_s3_bucket_policy" "environment_logs_bucket_policy" {
  bucket = aws_s3_bucket.environment_logs_bucket.id

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
      "Resource": "${aws_s3_bucket.environment_logs_bucket.arn}"
    },
    {
      "Sid": "Get Bucket ACL needed for S3 logging",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.environment_logs_bucket.arn}"
    },
    {
      "Sid": "Put object needed for S3 logging",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.environment_logs_bucket.arn}/*",
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

resource "aws_s3_bucket_public_access_block" "environment_logs_bucket_block_public_access" {
  bucket = aws_s3_bucket.environment_logs_bucket.id

  block_public_acls   = true
  block_public_policy = true
}
