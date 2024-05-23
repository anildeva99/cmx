resource "aws_db_instance" "mirth_database" {
  allocated_storage               = var.mirth_database_allocated_storage_gb
  allow_major_version_upgrade     = false
  auto_minor_version_upgrade      = true
  backup_retention_period         = var.mirth_database_backup_retention_period
  copy_tags_to_snapshot           = true
  db_subnet_group_name            = aws_db_subnet_group.mirth_database_subnet_group.name
  deletion_protection             = var.mirth_database_deletion_protection
  enabled_cloudwatch_logs_exports = var.mirth_database_enabled_cloudwatch_logs_exports
  engine                          = "postgres"
  engine_version                  = var.mirth_database_version
  final_snapshot_identifier       = var.mirth_database_identifier
  identifier                      = var.mirth_database_identifier
  instance_class                  = var.mirth_database_instance_class
  kms_key_id                      = aws_kms_key.mirth_database_kms_key.arn
  max_allocated_storage           = var.mirth_database_max_allocated_storage_gb
  monitoring_interval             = var.mirth_database_monitoring_interval
  monitoring_role_arn             = aws_iam_role.rds_enhanced_monitoring.arn
  multi_az                        = var.mirth_database_multi_az
  name                            = var.mirth_database_name
  parameter_group_name            = aws_db_parameter_group.mirth_database_parameter_group.name
  password                        = var.database_temporary_password
  port                            = 5432
  storage_encrypted               = true
  storage_type                    = "gp2"
  username                        = var.mirth_database_admin_username
  vpc_security_group_ids          = [aws_security_group.mirth_database_sg.id]

  timeouts {
    create = "80m"
    update = "80m"
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "mirth_database"
      Name = "CodaMetrix Traffic Cop RDS - mirth_database"
    }
  )
}

resource "aws_db_parameter_group" "mirth_database_parameter_group" {
  name   = var.mirth_database_parameter_group
  family = "postgres11"

  parameter {
    apply_method = "pending-reboot"
    name         = "rds.force_ssl"
    value        = "1"
  }
}

resource "aws_db_subnet_group" "mirth_database_subnet_group" {
  name        = var.mirth_database_subnet_group_name
  subnet_ids  = var.mirth_database_subnet_group_subnet_ids
  description = "Subnet groups that the mirth RDS database will be created in"

  tags = merge(
    var.shared_resource_tags,
    {
      Name             = "CodaMetrix Traffic Cop RDS - mirth_database_subnet_group"
      SubenetGroupName = var.mirth_database_subnet_group_name
    }
  )
}
