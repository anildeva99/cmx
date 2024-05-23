resource "aws_db_instance" "application_database" {
  allocated_storage               = var.application_database_size
  allow_major_version_upgrade     = false
  auto_minor_version_upgrade      = var.application_database_multi_az ? true : false
  backup_retention_period         = var.application_database_backup_retention_period
  copy_tags_to_snapshot           = true
  db_subnet_group_name            = aws_db_subnet_group.application_database_subnet_group.name
  deletion_protection             = var.application_database_deletion_protection
  enabled_cloudwatch_logs_exports = var.application_database_enabled_cloudwatch_logs_exports
  engine                          = "postgres"
  engine_version                  = var.application_database_version
  final_snapshot_identifier       = var.application_database_identifier
  identifier                      = var.application_database_identifier
  instance_class                  = var.application_database_instance_class
  kms_key_id                      = aws_kms_key.application_database_kms_key.arn
  monitoring_interval             = var.application_database_monitoring_interval
  monitoring_role_arn             = aws_iam_role.rds_enhanced_monitoring.arn
  multi_az                        = var.application_database_multi_az
  name                            = var.application_database_name
  parameter_group_name            = aws_db_parameter_group.application_database_parameter_group.name
  password                        = var.database_temporary_password
  port                            = 5432
  storage_encrypted               = true
  storage_type                    = "gp2"
  username                        = var.application_database_admin_username
  vpc_security_group_ids          = [aws_security_group.application_database_sg.id]

  timeouts {
    create = "80m"
    update = "80m"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_database"
      Name = "CodaMetrix Application - application_database"
    }
  )
}

resource "aws_db_parameter_group" "application_database_parameter_group" {
  name   = "codametrixapplication-${var.environment}-parameter-group"
  family = "postgres11"

  parameter {
    apply_method = "pending-reboot"
    name         = "rds.force_ssl"
    value        = "1"
  }
}

resource "aws_db_subnet_group" "application_database_subnet_group" {
  name        = var.application_database_subnet_group_name
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  description = "Subnet groups that the application RDS database will be created in"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_database_subnet_group"
      Type = "application_database_subnet_group"
    }
  )
}

output "application_database_address" {
  value = aws_db_instance.application_database.address
}

output "application_database_dbname" {
  value = aws_db_instance.application_database.name
}
