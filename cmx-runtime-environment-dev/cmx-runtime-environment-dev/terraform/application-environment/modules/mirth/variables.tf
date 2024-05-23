####################
# Environment basics
####################
# Environment name. Something like 'sandbox', 'development', etc.
variable "environment" {
  description = "Environment name (sandbox, development, etc.)"
  type        = string
}

# AWS Region
variable "aws_region" {
  default     = "us-east-1"
  description = "AWS region to build infrastructure within"
  type        = string
}

variable "shared_resource_tags" {
  description = "Common tags applied to all resources"
  type        = map
}

variable "iam_resource_path" {
  default     = "/"
  description = "Default path for IAM policies"
  type        = string
}

variable "database_temporary_password" {
  description = "Temporary password that will be used for all databases (Postgres, Redis, etc)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

###########
# IAM stuff
###########
variable "mirth_role_name" {
  description = "Name of the role that the Mirth container will assume"
  type        = string
}

variable "eks_node_instance_role_arn" {
  description = "ARN of the EKS worker node instance role"
  type        = string
}

variable "attach_ingest_bucket_and_key_policies" {
  description = "Used as a boolean in conditional for whether to give Mirth access to the Ingest bucket / key"
  type        = number
}

variable "healthsystem_ingest_bucket_usage_policy_arn" {
  description = "ARN of the IAM policy that gives access to the healthsystem-level ingest buckets"
  type        = string
}

variable "temp_bucket_usage_policy_arn" {
  description = "ARN of the IAM policy that gives access to the temp bucket for Mirth"
  type        = string
}

####################
# RDS database stuff
####################
variable "mirth_database_identifier" {
  description = "RDS resource name for the mirth database"
  type        = string
}

variable "mirth_database_name" {
  default     = "mirthdb"
  description = "Mirth database name"
  type        = string
}

variable "mirth_database_admin_username" {
  description = "Mirth database admin username"
  type        = string
}

variable "mirth_database_size" {
  default     = 10
  description = "DB vol size"
  type        = number
}

variable "mirth_database_version" {
  default     = "11.8"
  description = "PostgreSQL version to use for DB instance"
  type        = string
}

# db.t3.small = 1vCPUs, 1 GiB RAM
variable "mirth_database_instance_class" {
  default     = "db.t3.small"
  description = "RDS instance type"
  type        = string
}

variable "mirth_database_backup_retention_period" {
  default     = 7
  description = "Number of days to retain backups"
  type        = number
}

variable "mirth_database_deletion_protection" {
  default     = true
  description = "Protect database from deletion"
  type        = bool
}

variable "mirth_database_enabled_cloudwatch_logs_exports" {
  default     = ["postgresql", "upgrade", "error", "slowquery"]
  description = "List of log types to export to CloudWatch logs"
  type        = list(string)
}

variable "mirth_database_monitoring_interval" {
  default     = 30
  description = "Interval, in seconds, that enhanced monitoring metrics will be collected"
  type        = number
}

variable "mirth_database_subnet_group_name" {
  description = "Subnet Group name for the Mirth Database"
  type        = string
}

variable "mirth_database_subnet_group_subnet_ids" {
  description = "List of subnets for the Mirth database subnet group"
  type        = list(string)
}

variable "mirth_database_secrets_usage_policy_name" {
  description = "Database secrets usage policy name for Mirth"
  type        = string
}

variable "mirth_database_kms_key_alias" {
  description = "Database KMS key alias for Mirth"
  type        = string
}

variable "mirth_database_parameter_group" {
  description = "Database parameter group name for Mirth"
  type        = string
}

variable "mirth_database_secret_name" {
  description = "Database secret name for Mirth"
  type        = string
}

variable "mirth_database_admin_secret_name" {
  description = "Database admin secret name for Mirth"
  type        = string
}

variable "mirth_database_security_group_name" {
  description = "Database security group name for Mirth"
  type        = string
}

variable "mirth_rds_enhanced_monitoring_role_name" {
  description = "Enhanced monitoring role for Mirth RDS"
  type        = string
}

variable "mirth_database_multi_az" {
  default     = false
  description = "Enable/disable multi_az for Mirth database"
  type        = bool
}

###############
# Secrets stuff
###############
variable "secrets_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt secrets"
  type        = string
}

variable "mirth_database_secret_recovery_window_days" {
  description = "Number of days to allow recovery of mirth database secrets"
  type        = number
}

variable "mirth_database_username" {
  default     = "mirthdb"
  description = "Username of the Mirth database user"
  type        = string
}

#####################
#Security Group stuff
#####################
variable "mirth_instance_sg_id" {
  description = "ID of the Mirth instance security group"
  type        = string
}

variable "bastion_sg_id" {
  description = "ID of the bastion host security group"
  type        = string
}
