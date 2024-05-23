####################
# Environment basics
####################
# Environment name. Something like 'sandbox', 'development', etc.
variable "environment" {
  default     = "sandbox"
  type        = string
  description = "Environment name (sandbox, development, etc.)"
}

# AWS Region
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
  description = "Temporary password that will be used for all databases (Postgres, Redis, etc)"
}

variable "iam_resource_path" {
  type    = string
  default = "/"
}

variable "sns_topics" {
  type    = map
}

variable "environment_logs_bucket" {
  type        = string
  description = "Environment logs bucket"
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

###################
# Dundas stuff
###################
variable "dundas_amis" {
  type = map
}

variable "dundas_instance_role" {
  type = string
}

variable "dundas_autoscaling_group" {
  type = map
}

variable "dundas_instance_type" {
  type = string
}

variable "alb_dundas_ingress_from_cidr_sgs" {
  type = list(object({
            description = string
            from_port = string
            to_port = string
            protocol = string
            cidr_blocks = list(string)
         }))
  description = "List of security groups rules to open the Dundas ALB to a list of CIDR blocks"
}

variable "alb_dundas_ingress_from_sg_sgs" {
  type = list(object({
          description = string
          from_port = string
          to_port = string
          protocol = string
          source_security_group_id = string
       }))
  description = "List of security groups rules to open the Dundas ALB to another security group (by ID)"
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
            from_port = string
            to_port = string
            protocol = string
            cidr_blocks = list(string)
         }))
  description = "List of security groups rules to open the bastion to a list of CIDR blocks"
}

variable "bastion_ingress_from_sg_sgs" {
  type = list(object({
            description = string
            from_port = string
            to_port = string
            protocol = string
            source_security_group_id = string
         }))
  description = "List of security groups rules to open the bastion to another security group (by ID)"
}

############################
# Dundas database (RDS)
############################
variable "dundas_application_database_identifier" {
  type        = string
  description = "RDS resource name for the Dundas application database"
}

variable "dundas_application_database_name" {
  type        = string
  description = "Dundas application database name"
}

variable "dundas_application_database_admin_username" {
  type        = string
  description = "Dundas application database admin username"
}

variable "dundas_application_database_size" {
  type    = number
  default = 500
}

variable "dundas_application_database_version" {
  type    = string
  default = "11.2"
}

# db.t3.xlarge = 4vCPUs, 16 GiB RAM
variable "dundas_application_database_instance_class" {
  type    = string
  default = "db.t3.xlarge"
}

variable "dundas_application_database_backup_retention_period" {
  type        = number
  description = "Number of days to retain backups"
}

variable "dundas_application_database_deletion_protection" {
  type        = bool
  description = "Protect database from deletion"
  default     = true
}

variable "dundas_application_database_additional_ingress_sgs" {
  type        = list(string)
  description = "List of additional SG Ids to enable for ingress to the Dundas application database"
}

variable "dundas_application_database_enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to CloudWatch logs"
  default     = ["postgresql", "upgrade", "error", "slowquery"]
}

variable "dundas_application_database_monitoring_interval" {
  type        = number
  description = "Interval, in seconds, that enhanced monitoring metrics will be collected"
  default     = 30
}

variable "dundas_application_database_subnet_group_name" {
  type        = string
  description = "Subnet Group name for the Dundas application Database"
}

variable "dundas_application_database_secret_recovery_window_days" {
  type        = number
  description = "Number of days to allow recovery of Dundas application database secrets"
}

variable "dundas_warehouse_database_identifier" {
  type        = string
  description = "RDS resource name for the warehouse database"
}

variable "dundas_warehouse_database_name" {
  type        = string
  description = "Dundas warehouse database name"
}

variable "dundas_warehouse_database_admin_username" {
  type        = string
  description = "Dundas warehouse database admin username"
}

variable "dundas_warehouse_database_size" {
  type    = number
  default = 500
}

variable "dundas_warehouse_database_version" {
  type    = string
  default = "11.2"
}

# db.t3.xlarge = 4vCPUs, 16 GiB RAM
variable "dundas_warehouse_database_instance_class" {
  type    = string
  default = "db.t3.xlarge"
}

variable "dundas_warehouse_database_backup_retention_period" {
  type        = number
  description = "Number of days to retain backups"
}

variable "dundas_warehouse_database_deletion_protection" {
  type        = bool
  description = "Protect database from deletion"
  default     = true
}

variable "dundas_warehouse_database_additional_ingress_sgs" {
  type        = list(string)
  description = "List of additional SG Ids to enable for ingress to the warehouse database"
}

variable "dundas_warehouse_database_enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to CloudWatch logs"
  default     = ["postgresql", "upgrade", "error", "slowquery"]
}

variable "dundas_warehouse_database_monitoring_interval" {
  type        = number
  description = "Interval, in seconds, that enhanced monitoring metrics will be collected"
  default     = 30
}

variable "dundas_warehouse_database_subnet_group_name" {
  type        = string
  description = "Subnet Group name for the dundas warehouse Database"
}

variable "dundas_warehouse_database_secret_recovery_window_days" {
  type        = number
  description = "Number of days to allow recovery of warehouse database secrets"
}

variable "dundas_warehouse_database_username" {
  type        = string
  description = "Dundas user account for dundas warehouse Database"
}

variable "dundas_application_database_username" {
  type        = string
  description = "Dundas user account for dundas application Database"
}

variable "dundas_ses_identity" {
  type        = string
  description = "Dundas account for SMTP"
}

variable "dundas_keypair_public_key" {
  type        = string
  description = "Public key for the Dundas server keypair"
}

variable "dundas_key_name" {
  type        = string
  description = "Name of the Dundas server keypair"
}

###############
# Secrets stuff
###############
# Environment secrets key alias
variable "environment_secrets_kms_key_alias" {
  type        = string
  description = "KMS Key alias for environment secrets"
}

# Dundas secrets key alias
variable "dundas_secrets_kms_key_alias" {
  type        = string
  description = "KMS Key alias for dundas secrets"
}

# Dundas secrets key name
variable "dundas_config_secret_name" {
  type        = string
  description = "Name for Config Secret for Dundas"
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


############
# WAF Stuff
############
variable "waf_regional_prefix" {
  default     = "regional"
  type        = string
  description = "AWS WAF name prefix"
}

variable "blacklisted_ips" {
  default     = []
  type        = list
  description = "List of ips to be blocked by WAF"
}

variable "admin_remote_ipset" {
  default     = []
  type        = list
  description = "List of ip to be blocked as remote admin"
}

variable "acl_constraint_body_size" {
  default     = 4096
  type        = number
  description = "Maximum number of bytes allowed in the body of the request. If you do not plan to allow large uploads, set it to the largest payload value that makes sense for your web application. Accepting unnecessarily large values can cause performance issues, if large payloads are used as an attack vector against your web application."
}

variable "acl_constraint_cookie_size" {
  default     = 4093
  type        = number
  description = "Maximum number of bytes allowed in the cookie header. The maximum size should be less than 4096, the size is determined by the amount of information your web application stores in cookies. If you only pass a session token via cookies, set the size to no larger than the serialized size of the session token and cookie metadata."
}

variable "acl_constraint_query_string_size" {
  default     = 1024
  type        = number
  description = "Maximum number of bytes allowed in the query string component of the HTTP request. Normally the  of query string parameters following the ? in a URL is much larger than the URI , but still bounded by the  of the parameters your web application uses and their values."
}

variable "acl_constraint_uri_size" {
  default     = 512
  type        = number
  description = "Maximum number of bytes allowed in the URI component of the HTTP request. Generally the maximum possible value is determined by the server operating system (maps to file system paths), the web server software, or other middleware components. Choose a value that accomodates the largest URI segment you use in practice in your web application."
}

variable "web_admin_url" {
  default     = "/admin"
  type        = string
  description = "The url that web admin request starts with"
}

variable "acl_constraint_match_auth_tokens" {
  default     = ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
  type        = string
  description = "JSON Web Token signature portion which is  hijacked"
}

variable "acl_constraint_session_id" {
  default     = ""
  type        = string
  description = "Session id contained in cookie which is  hijacked"
}

###############################
# Security Tools related
###############################
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

variable "env_vpc_flow_log_group_name" {
  type        = string
  description = "VPC Flow Log group name"
}

variable "env_vpc_flow_log_traffic_type" {
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
#  CloudWatch Alarms
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

variable "cloud_watch_alarm_topic_display_name" {
  type        = string
  description = "Display name of SNS topic of cloud watch alarms"
}

variable "low_storage_space_cloudwatch_alarm" {
  type        = map(map(map(string)))
  description = "The map containing db_identifier,  other parameters of a database low free storage space alarm."
}

variable "dundas_server_liveness_threshold" {
  type        = number
  description = "Expected 'StatusCheckFailed' count for alerting on Dundas server liveness"
}

########################
#  AWS KMS key rotation
########################
variable "enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled"
}
