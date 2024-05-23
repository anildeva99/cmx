resource "tls_private_key" "emr_spark_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "emr_spark_cert" {
  key_algorithm         = "RSA"
  private_key_pem       = tls_private_key.emr_spark_key.private_key_pem
  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["*.${var.aws_region}.compute.internal"]

  subject {
    common_name  = "*.${var.aws_region}.compute.internal"
    organization = "Codametrix"
    province     = "MA"
    country      = "US"
  }
}

data "archive_file" "emr_spark_certs_file" {
  type        = "zip"
  output_path = var.emr_spark_certs_file_path

  source {
    content  = tls_private_key.emr_spark_key.private_key_pem
    filename = "privateKey.pem"
  }

  source {
    content  = tls_self_signed_cert.emr_spark_cert.cert_pem
    filename = "certificateChain.pem"
  }

  source {
    content  = tls_self_signed_cert.emr_spark_cert.cert_pem
    filename = "trustedCertificates.pem"
  }
}

resource "aws_s3_bucket_object" "emr_spark_certs" {
  key    = "emr_spark_certs.zip"
  bucket = aws_s3_bucket.application_configuration_bucket.bucket
  source = var.emr_spark_certs_file_path
}
