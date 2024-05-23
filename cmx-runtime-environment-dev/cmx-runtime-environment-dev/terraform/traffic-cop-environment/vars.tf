####################
# Environment basics
####################
variable "environment" {
  default     = "tc1"
  type        = string
  description = "Environment name (tc1, tc2, etc.)"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "sso_login_account_id" {
  type        = string
  description = "The ID of the AWS account used for SSO login"
}

variable "peer_vpc_routes" {
  type        = map
  description = "A map of peering connection names and associated route CIDR blocks to add for them"
}

# Common tags applied to all resources
variable "shared_resource_tags" {
  type = map
}

variable "environment_dns_name" {
  type        = string
  description = "DNS address for the entire environment (DNS zone)"
}

variable "database_temporary_password" {
  type        = string
  description = "Temporary password that will be used for all databases (Postgres, etc)"
}

variable "iam_resource_path" {
  type    = string
  default = "/"
}

variable "logs_bucket" {
  type        = string
  description = "Application logs bucket"
}

###########
# VPC Stuff
###########
# VPC CIDR block
variable "vpc_cidr_block" {
  type = string
}

# VPC Subnet CIDR block prefix
variable "vpc_subnet_cidr_block_prefix" {
  type = string
}

# VPC Subnet CIDR block suffix
variable "vpc_subnet_cidr_block_suffix" {
  type = string
}

variable "customerrouter_amis" {
  type        = map
  description = "AMIs to use for the customer routers (Cisco CSR)"
}

variable "customerrouter_instance_type" {
  type        = string
  description = "Instance type for the customer routers (Cisco CSR)"
  default     = "t2.medium"
}

variable "customerrouter_key_name" {
  type        = string
  description = "Key name for the customer routers (Cisco CSR)"
}

variable "customerrouter_public_key" {
  type        = string
  description = "Public key for the customer routers (Cisco CSR)"
}

variable "partners_vpn_secret_recovery_window_days" {
  type = number
}

variable "partners_ingress_open_ports" {
  type        = list(string)
  description = "Ports used for sending / receiving Partners traffic to Mirth"
}

variable "cumedicine_vpn_secret_recovery_window_days" {
  type = number
}

variable "cumedicine_ingress_open_ports" {
  type        = list(string)
  description = "Ports used for sending / receiving CU Medicine traffic to Mirth"
}

variable "yale_vpn_secret_recovery_window_days" {
  type = number
}

variable "yale_ingress_open_ports" {
  type        = list(string)
  description = "Ports used for sending / receiving Yale traffic to Mirth"
}

##########
# Firehose
##########
variable "firehose_lambda_function_dir" {
  type        = string
  description = "The path of firehose lambda function."
}

variable "cloud_watch_ingest_to_elasticsearch_log_groups" {
  type        = map(map(string))
  description = "The map containing name, arn, shard_count of log group of the services to ingest to Elastic Search."
}

variable "firehose_lambda_runtime_type" {
  type        = string
  description = "The runtime virtual machine used to execute  lambda function of Firehose record transformation."
}

variable "firehose_lambda_function_timeout" {
  type        = number
  description = "The amount of time the Lambda Function has to run in seconds. Defaults to 3."
}

variable "firehose_cloudwatch_log_retention" {
  type        = number
  description = "The number of days the log events are retained in the specified log group."
}

variable "kinesis_rentention_period" {
  type        = number
  description = "Length of time data records are accessible after they are added to the stream. The maximum value of a stream's retention period is 168 hours. Minimum value is 24. Default is 24."
}

variable "log_subscription_filter_distribution" {
  type        = string
  description = "The method used to distribute log data to the destination."
}

variable "firehose_elasticsearch_configuration_buffering_interval" {
  type        = number
  description = "Buffer incoming data for the specified period of time, in seconds between 60 to 900."
}

variable "firehose_elasticsearch_configuration_buffering_size" {
  type        = number
  description = "Buffer incoming data to the specified size, in MBs between 1 to 100, before delivering it to the destination."
}

variable "firehose_s3_backup_bucket_configuration_buffering_interval" {
  type        = number
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300."
}

variable "firehose_s3_backup_bucket_configuration_buffering_size" {
  type        = number
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5."
}

variable "firehose_s3_backup_bucket_configuration_prefix" {
  type        = string
  description = "An extra prefix to be added in front of the time format prefix. The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files."
}

variable "firehose_s3_config_cloudwatch_logging_options_enabled" {
  type        = bool
  description = "The CloudWatch Logging Options for the delivery stream."
}

variable "firehose_s3_config_cloudwatch_logging_options_log_group_name" {
  type        = string
  description = "The CloudWatch group name for logging of Firehose Stream. This value is required if enabled is true."
}

variable "firehose_s3_config_cloudwatch_logging_options_log_stream_name" {
  type        = string
  description = "The CloudWatch log stream name for logging of Firehose stream. This value is required if enabled is true. "
}

variable "firehose_elasticsearch_configuration_s3_backup_mode" {
  type        = string
  description = "Defines how documents should be delivered to Amazon S3. Valid values are FailedDocumentsOnly and AllDocuments. Default value is FailedDocumentsOnly. "
}

variable "firehose_elasticsearch_configuration_index_rotation_period" {
  type        = string
  description = "The Elasticsearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data."
}

variable "firehose_record_lambda_func_processing_configuration_enabled" {
  type        = bool
  description = "Enables or disables data processing."
}

variable "firehose_record_processors_type" {
  type        = string
  description = "The type of processor. Valid Values: Lambda"
}

variable "firehose_processor_parameter_name" {
  type        = string
  description = "Parameter name. Valid Values: LambdaArn, NumberOfRetries, RoleArn, BufferSizeInMBs, BufferIntervalInSeconds. "
}

variable "kinesis_stream_kms_key_alias" {
  type        = string
  description = "Alias of the GUID for the customer-managed KMS key to use for encryption. "
}

##############
# Bastion host
##############
variable "bastion_instance_type" {
  type        = string
  description = "Instance type for the bastion host"
  default     = "t3.micro"
}

# Bastion stuff
variable "bastion_amis" {
  type = map
}

variable "bastion_host_key_name" {
  type        = string
  description = "AWS Key Pair name for the bastion host"
}

variable "bastion_host_public_key" {
  type        = string
  description = "AWS Public Key for the bastion host keypair"
}

variable "bastion_ingress_from_cidr_sgs" {
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of security groups rules to open the bastion to a list of CIDR blocks"
}

variable "bastion_ingress_from_sg_sgs" {
  type = list(object({
    description              = string
    from_port                = string
    to_port                  = string
    protocol                 = string
    source_security_group_id = string
  }))
  description = "List of security groups rules to open the bastion to another security group (by ID)"
}

###############
# Secrets stuff
###############
# Secrets key alias
variable "secrets_kms_key_alias" {
  type        = string
  description = "KMS Key alias for secrets"
}

# Recovery Window
variable "aws_secrets_recovery_window_in_days" {
  type        = number
  description = "Recovery window for AWS Secrets in days"
}

# Initial value of AWS secret for ssh keypairs
variable "aws_secret_manager_secret_key_initial_value" {
  type = string
}

###########################
# SNS Topics and SQS Queues
###########################
# Map of SNS topics
variable "sns_topics" {
  type        = map
  description = "Mapping of SNS topics, e.g. { event_topic: { name: '<Topic Name>', display_name: '<Topic Display Name>' } }"
}

#################
# Engineer stuff
#################
# An array of engineer objects with 'name' and 'email' properties
variable "engineers" {
  type        = list
  description = "Engineers for whom we are creating resources"
  default     = []
}

variable "engineer_policy_arns" {
  type        = list
  description = "Policy ARNs to assign to engineers"
  default     = []
}

#############
# Mirth stuff
#############
variable "mirthconnect_dns_address" {
  type        = string
  description = "DNS name for Mirth"
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

variable "mirth_database_version" {
  type    = string
  default = "11.2"
}

variable "mirth_database_multi_az" {
  default     = false
  description = "Enable/disable multi_az for Mirth database"
  type        = bool
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

variable "mirth_database_secret_recovery_window_days" {
  type        = number
  description = "Number of days to allow recovery of mirth database secrets"
}

variable "mirth_database_username" {
  type        = string
  description = "Username of the Mirth database user"
  default     = "mirthdb"
}

variable "mirth_role_name" {
  type        = string
  description = "Name of the role that the Mirth instance will assume"
}

variable "mirth_database_identifier" {
  type        = string
  description = "RDS resource name for the mirth database"
}

variable "mirth_database_allocated_storage_gb" {
  type    = number
  default = 256
}

variable "mirth_database_max_allocated_storage_gb" {
  type    = number
  default = 1024
}

# db.t3.xlarge = 4vCPUs, 16 GiB RAM
variable "mirth_database_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "mirth_database_subnet_group_name" {
  type        = string
  description = "Subnet Group name for the Mirth database"
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

variable "mirth_amis" {
  type        = map
  description = "AMIs to use for mirth"
}

variable "mirth_key_name" {
  type        = string
  description = "AWS Key Pair name for mirth"
}

variable "mirth_public_key" {
  type        = string
  description = "AWS Public Key for the mirth keypair"
}

variable "mirth_instance_type" {
  type        = string
  description = "EC2 instance type for mirth"
}

variable "mirth_additional_open_ports" {
  type        = list
  description = "Additional ports to open for Mirth"
}

#####################
# Elasticsearch Stuff
#####################
variable "elasticsearch_domain" {
  type        = string
  description = "Elasticsearch domain"
}

variable "elasticsearch_version" {
  type        = string
  description = "Elasticsearch version"
}

variable "elasticsearch_ebs_volume_size" {
  type        = string
  description = "EBS Volume Size in Gigabytes used for storing Elasticsearch data"
}

variable "elasticsearch_instance_type" {
  type        = string
  description = "ElasticSearch service instance type"
}

variable "elasticsearch_instance_count" {
  type        = number
  description = "ElasticSearch service instance count"
  default     = 1
}

variable "elasticsearch_dedicated_master_enabled" {
  type        = bool
  description = "ElasticSearch service use dedicated master nodes"
  default     = false
}

variable "elasticsearch_dedicated_master_count" {
  type        = number
  description = "ElasticSearch service dedicated master node count"
  default     = 1
}

variable "elasticsearch_zone_awareness_enabled" {
  type        = bool
  description = "ElasticSearch service multi-az deployment"
  default     = false
}

########################
# Security Tools related
########################
variable "aws_inspector_enabled" {
  default     = true
  description = "Set to false to disable all resources in this module."
}

variable "inspector_enable_scheduled_event" {
  type        = bool
  description = "Enable Cloudwatch Events to schedule an assessment"
}

variable "inspector_schedule_expression" {
  type        = string
  description = "AWS Schedule Expression: https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
}

variable "inspector_assessment_duration" {
  type        = string
  description = "The duration of the Inspector assessment run"
}

variable "ruleset_cve" {
  type        = bool
  description = "Enable Common Vulnerabilities and Exposures Ruleset"
}

variable "ruleset_cis" {
  type        = bool
  description = "Enable CIS Operating System Security Configuration Benchmarks Ruleset"
}

variable "aws_inspector_ruleset_region" {
  type        = string
  description = "AWS publish inspector rules in every region , but we pick us-east-1"
}

variable "aws_ruleset_account_id" {
  type        = string
  description = "AWS account id in which inspector rules are published"
}

variable "aws_ruleset_cve_id" {
  type = string
}

variable "aws_ruleset_cis_id" {
  type = string
}

variable "ruleset_security_best_practices_id" {
  type = string
}

variable "ruleset_network_reachability_id" {
  type = string
}

variable "ruleset_security_best_practices" {
  type        = bool
  description = "Enable AWS Security Best Practices Ruleset"
}

variable "ruleset_network_reachability" {
  type        = bool
  description = "Enable AWS Network Reachability Ruleset"
}

variable "guardduty_detector_enable" {
  type        = bool
  description = "Enable monitoring and feedback reporting"
}

variable "guardduty_master_account_id" {
  type        = string
  description = "Account ID for Guard Duty Master. Required if is_guardduty_member"
}

variable "vpc_flow_log_group_name" {
  type        = string
  description = "VPC Flow Log group name"
}

variable "vpc_flow_log_traffic_type" {
  type        = string
  description = "VPC Flow Log traffic type to capture"
}

variable "aws_foundations_securityhub_standards_subscription_arn" {
  type = string
}

variable "aws_securityhub_product_subscription_arn" {
  type = string
}

####################
# CloudWatch Alarms
####################
variable "free_storage_metrix_name" {
  type        = string
  description = "The name for the free storage space alarm's associated metric. "
}

variable "percentage_disk_space_used_metrix_name" {
  type        = string
  description = "The name for the percentage disk used alarm's associated metric. "
}

variable "less_than_or_equal_to_comparison_operator" {
  type        = string
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold: LessThanOrEqualToThreshold."
}

variable "greater_than_comparison_operator" {
  type        = string
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold: GreaterThanThreshold."
}
variable "statistic_period" {
  type        = string
  description = "The period in seconds over which the specified statistic is applied. "
}

variable "treat_missing_data" {
  type        = map(string)
  description = "Sets how this alarm is to handle missing data points as ignore"
}

variable "cloudwatch_alarm_namespace" {
  type        = map(string)
  description = "The namespace for the alarm's associated metric. "
}

variable "low_storage_space_cloudwatch_alarm" {
  type        = map(map(map(string)))
  description = "The map containing db_identifier,  other parameters of a database low free storage space alarm."
}

variable "mirth_alarms_enabled" {
  default     = false
  description = "Enable/Disable Mirth liveness and net throughput alarms"
  type        = bool
}

variable "mirth_liveness_threshold" {
  type        = number
  description = "Expected 'StatusCheckFailed' count for alerting on Mirth liveness"
  default     = 0
}

variable "mirth_network_throughput_threshold" {
  type        = number
  description = "Minimum network throughput threshold for alerting on Mirth liveness"
  default     = 0
}

variable "customerrouter_liveness_threshold" {
  type        = number
  description = "Expected 'StatusCheckFailed' count for alerting on Customer Router liveness"
  default     = 0
}

variable "customerrouter_network_throughput_threshold" {
  type        = number
  description = "Minimum network throughput threshold for alerting on Customer Router liveness"
  default     = 0
}

########################
#  AWS KMS key rotation
########################
variable "enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled"
}

variable "mirth_connect_api_ingress_from_cidr_sgs" {
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of security groups rules to open Mirth to a list of CIDR blocks"
}

variable "mirth_connect_api_ingress_from_sg_sgs" {
  type = list(object({
    description              = string
    from_port                = string
    to_port                  = string
    protocol                 = string
    source_security_group_id = string
  }))
  description = "List of security groups rules to open Mirth to another security group (by ID)"
}

##################################
# Index rotation for ElasticSearch
##################################
variable "elasticsearch_index_rotation" {
  type        = map
  description = "Parameter for rotating indices application of Elasticsearch cluster."
}

variable "elasticsearch_index_rotation_lambda" {
  type        = map
  description = "Parameters of lambda function of rotating indices for application of Elasticsearch cluster."
}

###########
# New Relic
###########
variable "new_relic_temporary_license_key" {
  type = string
}
