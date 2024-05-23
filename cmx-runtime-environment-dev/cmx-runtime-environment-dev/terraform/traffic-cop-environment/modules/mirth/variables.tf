####################
# Environment basics
####################
# Environment name. Something like 'sandbox', 'development', etc.
variable "environment" {
  type        = string
  description = "Environment name (sandbox, development, etc.)"
}

# AWS Region
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "shared_resource_tags" {
  type = map
}

variable "iam_resource_path" {
  type    = string
  default = "/"
}

variable "database_temporary_password" {
  type        = string
  description = "Temporary password that will be used for all databases (Postgres, Redis, etc)"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

###########
# IAM stuff
###########
variable "mirth_role_name" {
  type        = string
  description = "Name of the role that the Mirth container will assume"
}

variable "temp_bucket_usage_policy_arn" {
  type        = string
  description = "ARN of the IAM policy that gives access to the temp bucket for Mirth"
}

####################
# RDS database stuff
####################
variable "mirth_database_identifier" {
  type        = string
  description = "RDS resource name for the mirth database"
}

variable "mirth_database_name" {
  type        = string
  description = "Mirth database name"
  default     = "mirthdb"
}

variable "mirth_database_admin_username" {
  type        = string
  description = "Mirth database admin username"
}

variable "mirth_database_allocated_storage_gb" {
  type    = number
  default = 256
}

variable "mirth_database_max_allocated_storage_gb" {
  type    = number
  default = 1024
}

variable "mirth_database_version" {
  type    = string
  default = "11.2"
}

variable "mirth_database_multi_az" {
  default     = false
  description = "Enable/disable multi_az for Mirth database"
  type        = bool
}

# db.t3.xlarge = 4vCPUs, 16 GiB RAM
variable "mirth_database_instance_class" {
  type    = string
  default = "db.t3.xlarge"
}

variable "mirth_database_backup_retention_period" {
  type        = number
  description = "Number of days to retain backups"
}

variable "mirth_database_deletion_protection" {
  type        = bool
  description = "Protect database from deletion"
  default     = true
}

variable "mirth_database_enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to CloudWatch logs"
  default     = ["postgresql", "upgrade", "error", "slowquery"]
}

variable "mirth_database_monitoring_interval" {
  type        = number
  description = "Interval, in seconds, that enhanced monitoring metrics will be collected"
  default     = 30
}

variable "mirth_database_subnet_group_name" {
  type        = string
  description = "Subnet Group name for the Mirth Database"
}

variable "mirth_database_subnet_group_subnet_ids" {
  type        = list(string)
  description = "List of subnets for the Mirth database subnet group"
}

variable "mirth_database_secrets_usage_policy_name" {
  type        = string
  description = "Database secrets usage policy name for Mirth"
}

variable "mirth_database_kms_key_alias" {
  type        = string
  description = "Database KMS key alias for Mirth"
}

variable "mirth_database_parameter_group" {
  type        = string
  description = "Database parameter group name for Mirth"
}

variable "mirth_database_secret_name" {
  type        = string
  description = "Database secret name for Mirth"
}

variable "mirth_database_admin_secret_name" {
  type        = string
  description = "Database admin secret name for Mirth"
}

variable "mirth_database_security_group_name" {
  type        = string
  description = "Database security group name for Mirth"
}

variable "mirth_rds_enhanced_monitoring_role_name" {
  type        = string
  description = "Enhanced monitoring role for Mirth RDS"
}

###############
# Secrets stuff
###############
variable "secrets_kms_key_arn" {
  type        = string
  description = "ARN of the KMS key used to encrypt secrets"
}

variable "mirth_database_secret_recovery_window_days" {
  type        = number
  description = "Number of days to allow recovery of mirth database secrets"
}

variable "mirth_database_username" {
  type        = string
  description = "Username of the Mirth database user"
  default     = "mirthdb"
}

#####################
#Security Group stuff
#####################
variable "mirth_instance_sg_id" {
  type        = string
  description = "ID of the Mirth instance security group"
}

variable "bastion_sg_id" {
  type        = string
  description = "ID of the bastion host security group"
}
