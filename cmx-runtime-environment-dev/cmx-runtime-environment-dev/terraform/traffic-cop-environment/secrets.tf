resource "aws_secretsmanager_secret" "new_relic_license_key_secret" {
  name = "CMXTrafficCop/NewRelic/${var.environment}"
  description = "License key for Rew Relic in the '${var.environment}' environment."
  kms_key_id = aws_kms_key.secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "new_relic_license_key_secret"
      Name = "CodaMetrix Traffic Cop SecretsManager - new_relic_license_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "new_relic_license_key_secret_version" {
  secret_id = aws_secretsmanager_secret.new_relic_license_key_secret.id

  secret_string = <<EOF
{"license_key":"${var.new_relic_temporary_license_key}"}
EOF
}
