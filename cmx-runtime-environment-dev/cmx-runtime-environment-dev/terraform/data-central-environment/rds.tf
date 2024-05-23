###############
# Dundas DB
###############
resource "aws_db_instance" "dundas_application_database" {
  allocated_storage               = var.dundas_application_database_size
  allow_major_version_upgrade     = false
  auto_minor_version_upgrade      = true
  backup_retention_period         = var.dundas_application_database_backup_retention_period
  copy_tags_to_snapshot           = true
  db_subnet_group_name            = aws_db_subnet_group.dundas_application_database_subnet_group.name
  deletion_protection             = var.dundas_application_database_deletion_protection
  enabled_cloudwatch_logs_exports = var.dundas_application_database_enabled_cloudwatch_logs_exports
  engine                          = "postgres"
  engine_version                  = var.dundas_application_database_version
  final_snapshot_identifier       = var.dundas_application_database_identifier
  identifier                      = var.dundas_application_database_identifier
  instance_class                  = var.dundas_application_database_instance_class
  kms_key_id                      = aws_kms_key.dundas_application_database_kms_key.arn
  monitoring_interval             = var.dundas_application_database_monitoring_interval
  monitoring_role_arn             = aws_iam_role.rds_enhanced_monitoring.arn
  multi_az                        = true
  name                            = var.dundas_application_database_name
  parameter_group_name            = aws_db_parameter_group.dundas_application_database_parameter_group.name
  password                        = var.database_temporary_password
  port                            = 5432
  storage_encrypted               = true
  storage_type                    = "gp2"
  username                        = var.dundas_application_database_admin_username
  vpc_security_group_ids          = [aws_security_group.dundas_database_sg.id]

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_application_database"
      Name = "CodaMetrix Data Central - dundas_application_database"
    }
  )
}

resource "aws_db_parameter_group" "dundas_application_database_parameter_group" {
  name   = "codametrixdatacentral-${var.environment}-dundas-parameter-group"
  family = "postgres11"

  parameter {
    apply_method = "pending-reboot"
    name         = "rds.force_ssl"
    value        = "1"
  }
}

resource "aws_db_subnet_group" "dundas_application_database_subnet_group" {
  name        = var.dundas_application_database_subnet_group_name
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  description = "Subnet groups that the Dundas application RDS database will be created in"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central - dundas_application_database_subnet_group"
      Type = "dundas_application_database_subnet_group"
    }
  )
}

###############
# Dundas DB
###############
resource "aws_db_instance" "dundas_warehouse_database" {
  allocated_storage               = var.dundas_warehouse_database_size
  allow_major_version_upgrade     = false
  auto_minor_version_upgrade      = true
  backup_retention_period         = var.dundas_warehouse_database_backup_retention_period
  copy_tags_to_snapshot           = true
  db_subnet_group_name            = aws_db_subnet_group.dundas_warehouse_database_subnet_group.name
  deletion_protection             = var.dundas_warehouse_database_deletion_protection
  enabled_cloudwatch_logs_exports = var.dundas_warehouse_database_enabled_cloudwatch_logs_exports
  engine                          = "postgres"
  engine_version                  = var.dundas_warehouse_database_version
  final_snapshot_identifier       = var.dundas_warehouse_database_identifier
  identifier                      = var.dundas_warehouse_database_identifier
  instance_class                  = var.dundas_warehouse_database_instance_class
  kms_key_id                      = aws_kms_key.dundas_warehouse_database_kms_key.arn
  monitoring_interval             = var.dundas_warehouse_database_monitoring_interval
  monitoring_role_arn             = aws_iam_role.rds_enhanced_monitoring.arn
  multi_az                        = true
  name                            = var.dundas_warehouse_database_name
  parameter_group_name            = aws_db_parameter_group.dundas_warehouse_database_parameter_group.name
  password                        = var.database_temporary_password
  port                            = 5432
  storage_encrypted               = true
  storage_type                    = "gp2"
  username                        = var.dundas_warehouse_database_admin_username
  vpc_security_group_ids          = [aws_security_group.dundas_database_sg.id]

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_warehouse_database"
      Name = "CodaMetrix Data Central - dundas_warehouse_database"
    }
  )
}

resource "aws_db_parameter_group" "dundas_warehouse_database_parameter_group" {
  name   = "codametrixdatacentral-${var.environment}-dundas-warehouse-parameter-group"
  family = "postgres11"

  parameter {
    apply_method = "pending-reboot"
    name         = "rds.force_ssl"
    value        = "1"
  }
}

resource "aws_db_subnet_group" "dundas_warehouse_database_subnet_group" {
  name        = var.dundas_warehouse_database_subnet_group_name
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  description = "Subnet groups that the dundas warehouse RDS database will be created in"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central - dundas_warehouse_database_subnet_group"
      Type = "dundas_warehouse_database_subnet_group"
    }
  )
}
