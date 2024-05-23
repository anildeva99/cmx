resource "aws_secretsmanager_secret" "mirth_database_secret" {
  name                    = var.mirth_database_secret_name
  description             = "Mirth Database credentials for the '${var.environment}' environment."
  kms_key_id              = var.secrets_kms_key_arn
  recovery_window_in_days = var.mirth_database_secret_recovery_window_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type       = "mirth_database_secret"
      Name       = "CodaMetrix Traffic Cop SecretsManager - mirth_database_secret"
      SecretName = "${var.mirth_database_secret_name}"
    }
  )
}

resource "aws_secretsmanager_secret_version" "mirth_database_secret_version" {
  secret_id = aws_secretsmanager_secret.mirth_database_secret.id

  secret_string = <<EOF
{"dbusername":"${var.mirth_database_username}",
"dbpassword":"",
"dburl":"jdbc:postgresql://${aws_db_instance.mirth_database.address}/${var.mirth_database_name}?ssl=true&sslmode=require"}
EOF
}

resource "aws_secretsmanager_secret" "mirth_database_admin_secret" {
  name                    = var.mirth_database_admin_secret_name
  description             = "Mirth database credentials for '${var.mirth_database_admin_username}' in the '${var.environment}' environment."
  kms_key_id              = var.secrets_kms_key_arn
  recovery_window_in_days = 0

  tags = merge(
    var.shared_resource_tags,
    {
      Type       = "mirth_database_admin_secret"
      Name       = "CodaMetrix Traffic Cop SecretsManager - mirth_database_admin_secret"
      SecretName = "${var.mirth_database_admin_secret_name}"
    }
  )
}

resource "aws_secretsmanager_secret_version" "mirth_database_admin_secret_version" {
  secret_id = aws_secretsmanager_secret.mirth_database_admin_secret.id

  secret_string = <<EOF
{"dbusername":"${var.mirth_database_admin_username}",
"dbpassword":"${var.database_temporary_password}",
"dburl":"jdbc:postgresql://${aws_db_instance.mirth_database.address}/${var.mirth_database_name}?ssl=true&sslmode=require"}
EOF
}
