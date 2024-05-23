output "replica_instance_arn" {
  description = "AWS ARN of created replica instance"
  value       = aws_db_instance.replica_database.arn
}

output "replica_instance_id" {
  description = "ID of created replica instance"
  value       = aws_db_instance.replica_database.id
}
