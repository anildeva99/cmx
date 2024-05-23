provider "aws" {
  alias = "replica"
}

resource "aws_db_instance" "replica_database" {
  provider                        = aws.replica
  allocated_storage               = var.allocated_storage
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  db_subnet_group_name            = var.db_subnet_group_name
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  engine                          = "postgres"
  engine_version                  = var.engine_version
  identifier                      = var.identifier
  instance_class                  = var.instance_class
  kms_key_id                      = var.kms_key_arn
  max_allocated_storage           = var.max_allocated_storage
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn
  multi_az                        = var.multi_az
  parameter_group_name            = var.parameter_group_name
  port                            = 5432
  replicate_source_db             = var.source_db_arn
  skip_final_snapshot             = true
  storage_encrypted               = true
  storage_type                    = "gp2"
  tags                            = var.tags
  vpc_security_group_ids          = var.vpc_security_group_ids
  timeouts {
    create = "80m"
    update = "80m"
  }

}
