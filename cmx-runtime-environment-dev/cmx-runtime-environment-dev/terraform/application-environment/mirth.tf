module "mirth" {
  source = "./modules/mirth"

  # Standard variables
  aws_region                  = var.aws_region
  environment                 = var.environment
  shared_resource_tags        = var.shared_resource_tags
  iam_resource_path           = var.iam_resource_path
  database_temporary_password = var.database_temporary_password

  # Properties from the main stack.
  vpc_id                                      = aws_vpc.application_vpc.id
  eks_node_instance_role_arn                  = aws_iam_role.eks_node_instance_role.arn
  attach_ingest_bucket_and_key_policies       = 1
  healthsystem_ingest_bucket_usage_policy_arn = aws_iam_policy.application_healthsystem_ingest_bucket_usage_policy.arn
  temp_bucket_usage_policy_arn                = aws_iam_policy.mirth_temp_bucket_usage_policy.arn
  mirth_instance_sg_id                        = aws_security_group.application_worker_node_sg.id
  bastion_sg_id                               = aws_security_group.application_bastion_sg.id
  secrets_kms_key_arn                         = aws_kms_key.application_secrets_kms_key.arn

  # Mirth specific variables
  mirth_role_name                                = var.mirth_role_name
  mirth_database_identifier                      = var.mirth_database_identifier
  mirth_database_name                            = var.mirth_database_name
  mirth_database_admin_username                  = var.mirth_database_admin_username
  mirth_database_size                            = var.mirth_database_size
  mirth_database_version                         = var.mirth_database_version
  mirth_database_instance_class                  = var.mirth_database_instance_class
  mirth_database_backup_retention_period         = var.mirth_database_backup_retention_period
  mirth_database_deletion_protection             = var.mirth_database_deletion_protection
  mirth_database_enabled_cloudwatch_logs_exports = var.mirth_database_enabled_cloudwatch_logs_exports
  mirth_database_monitoring_interval             = var.mirth_database_monitoring_interval
  mirth_database_subnet_group_name               = var.mirth_database_subnet_group_name
  mirth_database_subnet_group_subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  mirth_database_secret_recovery_window_days     = var.mirth_database_secret_recovery_window_days
  mirth_database_username                        = var.mirth_database_username
  mirth_database_secrets_usage_policy_name       = var.mirth_database_secrets_usage_policy_name
  mirth_database_kms_key_alias                   = var.mirth_database_kms_key_alias
  mirth_database_parameter_group                 = var.mirth_database_parameter_group
  mirth_database_secret_name                     = var.mirth_database_secret_name
  mirth_database_admin_secret_name               = var.mirth_database_admin_secret_name
  mirth_database_security_group_name             = var.mirth_database_security_group_name
  mirth_rds_enhanced_monitoring_role_name        = var.mirth_rds_enhanced_monitoring_role_name
  mirth_database_multi_az                        = var.mirth_database_multi_az
}

module "ingress_mirth" {
  source = "./modules/mirth"

  # Standard variables
  aws_region                  = var.aws_region
  environment                 = var.environment
  shared_resource_tags        = var.shared_resource_tags
  iam_resource_path           = var.iam_resource_path
  database_temporary_password = var.database_temporary_password

  # Properties from the main stack.
  vpc_id                                      = aws_vpc.ingress_vpc.id
  eks_node_instance_role_arn                  = aws_iam_role.eks_node_instance_role.arn
  attach_ingest_bucket_and_key_policies       = 1
  healthsystem_ingest_bucket_usage_policy_arn = aws_iam_policy.application_healthsystem_ingest_bucket_usage_policy.arn
  temp_bucket_usage_policy_arn                = aws_iam_policy.mirth_temp_bucket_usage_policy.arn
  mirth_instance_sg_id                        = aws_security_group.ingress_mirth_sg.id
  bastion_sg_id                               = aws_security_group.ingress_bastion_sg.id
  secrets_kms_key_arn                         = aws_kms_key.application_secrets_kms_key.arn

  # Mirth specific variables
  mirth_role_name                                = var.ingress_mirth_role_name
  mirth_database_identifier                      = var.ingress_mirth_database_identifier
  mirth_database_name                            = var.mirth_database_name
  mirth_database_admin_username                  = var.mirth_database_admin_username
  mirth_database_size                            = var.ingress_mirth_database_size
  mirth_database_version                         = var.mirth_database_version
  mirth_database_instance_class                  = var.ingress_mirth_database_instance_class
  mirth_database_backup_retention_period         = var.mirth_database_backup_retention_period
  mirth_database_deletion_protection             = var.mirth_database_deletion_protection
  mirth_database_enabled_cloudwatch_logs_exports = var.mirth_database_enabled_cloudwatch_logs_exports
  mirth_database_monitoring_interval             = var.mirth_database_monitoring_interval
  mirth_database_subnet_group_name               = var.ingress_mirth_database_subnet_group_name
  mirth_database_subnet_group_subnet_ids         = [aws_subnet.ingress_private_subnet_1.id, aws_subnet.ingress_private_subnet_2.id]
  mirth_database_secret_recovery_window_days     = var.mirth_database_secret_recovery_window_days
  mirth_database_username                        = var.mirth_database_username
  mirth_database_secrets_usage_policy_name       = var.ingress_mirth_database_secrets_usage_policy_name
  mirth_database_kms_key_alias                   = var.ingress_mirth_database_kms_key_alias
  mirth_database_parameter_group                 = var.ingress_mirth_database_parameter_group
  mirth_database_secret_name                     = var.ingress_mirth_database_secret_name
  mirth_database_admin_secret_name               = var.ingress_mirth_database_admin_secret_name
  mirth_database_security_group_name             = var.ingress_mirth_database_security_group_name
  mirth_rds_enhanced_monitoring_role_name        = var.ingress_mirth_rds_enhanced_monitoring_role_name
  mirth_database_multi_az                        = var.ingress_mirth_database_multi_az
}
