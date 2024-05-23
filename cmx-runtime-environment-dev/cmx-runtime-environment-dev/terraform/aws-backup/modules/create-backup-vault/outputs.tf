output "src_region_vault_name" {
  description = "The name value of the backup vault in the src region"
  value       = aws_backup_vault.backup_vault_src_region.id
}

output "dst_region_vault_arn" {
  description = "The ARN value of the backup vault in the dst region"
  value       = aws_backup_vault.backup_vault_dst_region.arn
}
