output "mirth_database_secrets_usage_policy_arn" {
  value = aws_iam_policy.mirth_database_secrets_usage_policy.arn
}

output "mirth_role_arn" {
  value = aws_iam_role.mirth_role.arn
}

output "mirth_instance_profile" {
  value = aws_iam_instance_profile.mirth_instance_profile.name
}

output "mirth_database_kms_key_arn" {
  value = aws_kms_key.mirth_database_kms_key.arn
}

output "mirth_database_kms_key_id" {
  value = aws_kms_key.mirth_database_kms_key.key_id
}

output "mirth_database_kms_key_alias_arn" {
  value = aws_kms_alias.mirth_database_kms_key_alias.arn
}

output "mirth_database_address" {
  value = aws_db_instance.mirth_database.address
}

output "mirth_database_dbname" {
  value = aws_db_instance.mirth_database.name
}

output "mirth_database_arn" {
  value = aws_db_instance.mirth_database.arn
}

output "mirth_database_secret_arns" {
  value = aws_secretsmanager_secret.mirth_database_secret.arn
}

output "mirth_database_admin_secret_arns" {
  value = aws_secretsmanager_secret.mirth_database_admin_secret.arn
}

output "mirth_database_sg_arn" {
  value = aws_security_group.mirth_database_sg.arn
}
