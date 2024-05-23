variable "src_region" {
  default     = "us-east-1"
  description = "AWS region in which source RDS instance resides"
  type        = string
}

variable "dst_region" {
  default     = "us-west-2"
  description = "AWS region in which replica will reside"
  type        = string
}

variable "allocated_storage" {
  default     = 100
  description = "Min storage size of replica toa llocate at creation"
  type        = number
}

variable "allow_major_version_upgrade" {
  default     = false
  description = "Allow upgrade of major engin version"
  type        = bool
}

variable "auto_minor_version_upgrade" {
  default     = true
  description = "Allow auto upgrade of minor engine version"
  type        = bool
}

variable "copy_tags_to_snapshot" {
  default     = true
  description = "Copy tags to snapshots"
  type        = bool
}

# Required var
variable "db_subnet_group_name" {
  description = "Name of RDS subnet group to use for replica"
  type        = string
}

variable "deletion_protection" {
  default     = true
  description = "Enable/Disable deletion protection of replica instance"
  type        = bool
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to CloudWatch logs"
  default     = ["postgresql", "upgrade", "error", "slowquery"]
}

variable "engine_version" {
  default     = "11.8"
  description = "Postgresql engine version"
  type        = string
}

# Required var
variable "identifier" {
  description = "RDS replica name"
  type        = string
}

variable "instance_class" {
  default     = "db.t3.xlarge"
  description = "RDS instance class to use for replica"
  type        = string
}

# Required var
variable "kms_key_arn" {
  description = "ARN of the KMS  key to use for encryption of replica"
  type        = string
}

variable "max_allocated_storage" {
  default     = 16384
  description = "Max storage to auto-scale storage_size too"
  type        = number
}

variable "monitoring_interval" {
  default     = 30
  description = "Interval, in sec, to collect enhanced monitoring metrics"
  type        = number
}

# Required var
variable "monitoring_role_arn" {
  description = "ARN RDS monitoring role to use for enhanced metrics"
  type        = string
}

variable "multi_az" {
  default     = false
  description = "Whether to enable/disable multi-az for the RDS replica"
  type        = bool
}

variable "parameter_group_name" {
  description = "Name of RDS parameter group to use for replica"
  type        = string
}

# Required var
variable "source_db_arn" {
  description = "ARN of source RDS instance to replicate from"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to apply to RDS replica instance and snapshots"
  type        = map
}

# Required var
variable "vpc_security_group_ids" {
  description = "ID(s) of RDS security group(s) to place replica instance within"
  type        = list
}
