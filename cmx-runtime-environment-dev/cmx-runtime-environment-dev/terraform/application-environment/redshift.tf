resource "aws_redshift_cluster" "application_data_warehouse" {
  cluster_identifier        = var.application_data_warehouse_identifier
  database_name             = var.application_data_warehouse_name
  node_type                 = var.application_data_warehouse_node_type
  master_password           = var.database_temporary_password
  master_username           = var.application_data_warehouse_admin_username
  vpc_security_group_ids    = [aws_security_group.application_data_warehouse_sg.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.application_data_warehouse_subnet_group.name

  # Maintenance window
  #preferred_maintenance_window         = "ddd:hh24:mi-ddd:hh24:mi"

  cluster_parameter_group_name        = aws_redshift_parameter_group.application_data_warehouse_parameter_group.name
  automated_snapshot_retention_period = var.application_data_warehouse_snapshot_retention_period
  port                                = 5439
  cluster_version                     = var.application_data_warehouse_cluster_version
  allow_version_upgrade               = false
  number_of_nodes                     = var.application_data_warehouse_number_of_nodes
  publicly_accessible                 = false
  encrypted                           = true
  enhanced_vpc_routing                = true
  kms_key_id                          = aws_kms_key.application_data_warehouse_kms_key.arn
  skip_final_snapshot                 = false
  final_snapshot_identifier           = var.application_data_warehouse_identifier

  # Used to give Redshift access to S3 for logging and Redshift Spectrum
  iam_roles = [aws_iam_role.application_redshift_role.arn]

  logging {
    enable        = true
    bucket_name   = var.application_logs_bucket
    s3_key_prefix = var.application_data_warehouse_logging_prefix
  }

  // !!! PCD: Commenting out for now, not sure how to create the snapshot copy grant (below) in a different region
  // !!! which is what it seems to want.
  /*
  dynamic "snapshot_copy" {
    for_each  = length(keys(var.application_data_warehouse_snapshot_copy)) > 0 ? [ var.application_data_warehouse_snapshot_copy ] : []

    content {
      destination_region  = var.application_data_warehouse_snapshot_copy.region
      retention_period    = var.application_data_warehouse_snapshot_copy.retention_period
      grant_name          = aws_redshift_snapshot_copy_grant.application_data_warehouse_snapshot_copy_grant.snapshot_copy_grant_name
    }
  }
  */

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_warehouse"
      Name = "CodaMetrix Application - application_data_warehouse"
    }
  )
}

resource "aws_redshift_parameter_group" "application_data_warehouse_parameter_group" {
  name   = "codametrixapplication-${var.environment}-dw-parameter-group"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }

  parameter {
    name  = "statement_timeout"
    value = "600000" # Timeout queries that run longer than 10 minutes
  }
}

resource "aws_redshift_subnet_group" "application_data_warehouse_subnet_group" {
  name        = var.application_data_warehouse_subnet_group_name
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  description = "Subnet groups that the application data warehouse will be created in"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application - application_data_warehouse_subnet_group"
      Type = "application_data_warehouse_subnet_group"
    }
  )
}

resource "aws_redshift_snapshot_copy_grant" "application_data_warehouse_snapshot_copy_grant" {
  snapshot_copy_grant_name = "codametrixapplication-${var.environment}-dw-snapshot-copy-grant"
  kms_key_id               = aws_kms_key.application_data_warehouse_kms_key.arn
}

output "application_data_warehouse_address" {
  value = aws_redshift_cluster.application_data_warehouse.dns_name
}

output "application_data_warehouse_dbname" {
  value = aws_redshift_cluster.application_data_warehouse.database_name
}
