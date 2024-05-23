resource "aws_secretsmanager_secret" "application_database_secret" {
  name                    = "CodaMetrixApplication/Database/${var.environment}-${each.value}"
  for_each                = toset(var.services)
  description             = "Database credentials for '${each.value}' in the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_secrets_kms_key.arn
  recovery_window_in_days = var.application_database_secret_recovery_window_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type    = "application_database_secret"
      Name    = "CodaMetrix Application SecretsManager - application_database_secret"
      Service = "${each.value}"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_database_secret_version" {
  secret_id = aws_secretsmanager_secret.application_database_secret[each.value].id
  for_each                = toset(var.services)
  secret_string = <<EOF
{"dbusername":"${each.value}",
"dbpassword":"",
"dburl":"jdbc:postgresql://${aws_db_instance.application_database.address}/${each.value}?ssl=true&sslmode=require"}
EOF
}

resource "aws_secretsmanager_secret" "application_database_admin_secret" {
  name = "CodaMetrixApplication/DatabaseAdmin/${var.environment}"
  description = "Credentials for '${var.application_database_admin_username}' in the '${var.environment}' application environment."
  kms_key_id = aws_kms_key.application_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_database_admin_secret"
      Name = "CodaMetrix Application SecretsManager - application_database_admin_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_database_admin_secret_version" {
  secret_id = aws_secretsmanager_secret.application_database_admin_secret.id

  secret_string = <<EOF
{"dbusername":"${var.application_database_admin_username}",
"dbpassword":"${var.database_temporary_password}",
"dburl":"jdbc:postgresql://${aws_db_instance.application_database.address}/${var.application_database_name}?ssl=true&sslmode=require"}
EOF
}

resource "aws_secretsmanager_secret" "application_redis_secret" {
  name                    = "CodaMetrixApplication/Redis/${var.environment}"
  description             = "Redis credentials for the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_redis_secret"
      Name = "CodaMetrix Application SecretsManager - application_redis_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_redis_secret_version" {
  secret_id = aws_secretsmanager_secret.application_redis_secret.id

  secret_string = <<EOF
{"redisport":"6379",
"redispassword":"${var.elasticache_password}",
"redisaddress":"${aws_elasticache_replication_group.application_redis_replication_group.primary_endpoint_address}"}
EOF
}

resource "aws_secretsmanager_secret" "application_security_secret" {
  name = "CodaMetrixApplication/Security/${var.environment}"
  description = "Security credentials for the '${var.environment}' application environment."
  kms_key_id = aws_kms_key.application_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_security_secret"
      Name = "CodaMetrix Application SecretsManager - application_security_secret"
    }
  )
}

resource "aws_secretsmanager_secret" "application_oauth_process_secret" {
  name = "CodaMetrixApplication/OAuth/${var.environment}-processservice"
  description = "OAUTH Secret and Client ID for the '${var.environment}' application environment."
  kms_key_id = aws_kms_key.application_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_oauth_process_secret"
      Name = "CodaMetrix Application SecretsManager - application_oauth_process_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_oauth_process_secret_version" {
  secret_id = aws_secretsmanager_secret.application_oauth_process_secret.id

  secret_string = <<EOF
{"oauthid":"",
"oauthsecret":""}
EOF
}


resource "aws_secretsmanager_secret" "application_oauth_monitor_secret" {
  name = "CodaMetrixApplication/OAuth/${var.environment}-monitorservice"
  description = "OAUTH Secret and Client ID for the '${var.environment}' Monitor Service application environment."
  kms_key_id = aws_kms_key.application_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_oauth_monitor_secret"
      Name = "CodaMetrix Application SecretsManager - application_oauth_monitor_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_oauth_monitor_secret_version" {
  secret_id = aws_secretsmanager_secret.application_oauth_monitor_secret.id

  secret_string = <<EOF
{"oauthid":"",
"oauthsecret":""}
EOF
}

resource "aws_secretsmanager_secret_version" "application_security_secret_version" {
  secret_id = aws_secretsmanager_secret.application_security_secret.id

  secret_string = <<EOF
{"jwt_key":"${var.jwt_key_initial_value}"}
EOF
}

resource "aws_secretsmanager_secret" "application_data_warehouse_admin_secret" {
  name = "CodaMetrixApplication/DataWarehouseAdmin/${var.environment}"
  description = "Credentials for '${var.application_data_warehouse_admin_username}' in the '${var.environment}' application environment."
  kms_key_id = aws_kms_key.application_secrets_kms_key.arn
  recovery_window_in_days = var.application_data_warehouse_secret_recovery_window_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_warehouse_admin_secret"
      Name = "CodaMetrix Application SecretsManager - application_data_warehouse_admin_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_data_warehouse_admin_secret_version" {
  secret_id = aws_secretsmanager_secret.application_data_warehouse_admin_secret.id

  secret_string = <<EOF
{"dbusername":"${var.application_data_warehouse_admin_username}",
"dbpassword":"${var.database_temporary_password}",
"dburl":"jdbc:redshift://${aws_redshift_cluster.application_data_warehouse.endpoint}:5439/${var.application_data_warehouse_name}?ssl=true&sslmode=require"}
EOF
}

resource "aws_secretsmanager_secret" "new_relic_license_key_secret" {
  name = "CodaMetrixApplication/NewRelic/${var.environment}"
  description = "License key for Rew Relic in the '${var.environment}' application environment."
  kms_key_id = aws_kms_key.application_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "new_relic_license_key_secret"
      Name = "CodaMetrix Application SecretsManager - new_relic_license_key_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "new_relic_license_key_secret_version" {
  secret_id = aws_secretsmanager_secret.new_relic_license_key_secret.id

  secret_string = <<EOF
{"license_key":"${var.new_relic_temporary_license_key}"}
EOF
}

resource "aws_secretsmanager_secret" "application_smtp_secret" {
  name                    = "CodaMetrixApplication/SMTP/${var.environment}"
  description             = "SMTP credentials for the '${var.environment}' application environment."
  kms_key_id              = aws_kms_key.application_secrets_kms_key.arn
  recovery_window_in_days = var.aws_secrets_recovery_window_in_days

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_smtp_secret"
      Name = "CodaMetrix Application SecretsManager - application_smtp_secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "application_smtp_secret_version" {
  secret_id = aws_secretsmanager_secret.application_smtp_secret.id

  secret_string = <<EOF
{"address":"",
"username":"",
"password":""}
EOF
}

output "application_database_secret_arns" {
  value = values(aws_secretsmanager_secret.application_database_secret).*.arn
}

output "application_database_admin_secret_arn" {
  value = aws_secretsmanager_secret.application_database_admin_secret.arn
}

output "application_redis_secret_arn" {
  value = aws_secretsmanager_secret.application_redis_secret.arn
}

output "application_oauth_process_secret_arn" {
  value = aws_secretsmanager_secret.application_oauth_process_secret.arn
}

output "application_oauth_monitor_secret_arn" {
  value = aws_secretsmanager_secret.application_oauth_monitor_secret.arn
}

output "application_security_secret_arn" {
  value = aws_secretsmanager_secret.application_security_secret.arn
}

output "application_data_warehouse_admin_secret_arn" {
  value = aws_secretsmanager_secret.application_data_warehouse_admin_secret.arn
}

output "new_relic_license_key_secret_arn" {
  value = aws_secretsmanager_secret.new_relic_license_key_secret.arn
}
