resource "aws_s3_bucket" "developer_buckets" {
  for_each      = toset(keys(var.developers))
  bucket        = "${var.s3_bucket_prefix}.${each.value}.${var.environment}.app.codametrix.com"
  region        = var.aws_region
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = {
    Usage         = "CodaMetrix Development"
    Name          = "${var.s3_bucket_prefix}.${each.value}.${var.environment}.app.codametrix.com"
    DeveloperName = each.value
  }
}

output "s3_buckets" {
  value = aws_s3_bucket.developer_buckets
}
