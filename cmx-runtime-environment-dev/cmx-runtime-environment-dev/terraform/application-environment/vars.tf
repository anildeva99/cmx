####################
# Environment basics
####################
variable "environment" {
  default     = "sandbox"
  description = "Environment name (sandbox, development, etc.)"
  type        = string
}

variable "dr_environment" {
  description = "DR Environment name of environment"
  type        = string
}

variable "aws_region" {
  default     = "us-east-1"
  description = "AWS region in which environment resides"
  type        = string
}

variable "dr_region" {
  default     = "us-west-2"
  description = "AWS region in which dr_environment resides"
  type        = string
}

variable "enable_s3_replication" {
  default     = false
  description = "Enable/Disable S3 replication of buckets to dr_environment"
  type        = bool
}

variable "sso_login_account_id" {
  description = "The ID of the AWS account used for SSO login"
  type        = string
}

# !!! Remove these and replace with our own sagemaker-data bucket / key
variable "sagemaker_data_bucket" {
  description = "S3 bucket to place Sagemaker data within"
  type        = string
}

variable "sagemaker_data_key_alias_arn" {
  description = "KMS key to use to encrypt data within sagemaker_data_bucket"
  type        = string
}

variable "application_peer_vpc_routes" {
  description = "A map of peering connection names (in the application VPC) and associated route CIDR blocks to add for them"
  type        = map
}

variable "ingress_peer_vpc_routes" {
  description = "A map of peering connection names (in the ingress VPC) and associated route CIDR blocks to add for them"
  type        = map
}

variable "shared_resource_tags" {
  description = "Common tags applied to all resources"
  type        = map
}

# Health Systems
variable "healthsystems" {
  description = "List of CodaMetrix Health Systems"
  type        = list(string)
}

variable "cmx_api_public_whitelist" {
  description = "List of IP Addresses to Whitelist for External Access to CMX App"
  type        = list(string)
}

# Tenant->Health System map
variable "tenants" {
  description = "Map of CodaMetrix Tenants to Health System"
  type        = map(string)
}

variable "services" {
  description = "List of application microservices"
  type        = list(string)
}

variable "service_roles" {
  description = "Map of services to IAM roles"
  type        = map
}

variable "cmx_automate_dns_name" {
  description = "DNS address for CMX Automate (external URL)"
  type        = string
}

variable "application_env_dns_name" {
  description = "DNS address for the entire application environment (DNS zone)"
  type        = string
}

variable "application_api_dns_address" {
  description = "DNS address of the application API"
  type        = string
}

variable "application_static_dns_address" {
  description = "DNS address of the application static resources"
  type        = string
}

variable "application_www_dns_address" {
  description = "DNS address of the application www load balancer"
  type        = string
}

variable "database_temporary_password" {
  description = "Temporary password that will be used for all databases (Postgres, Redis, etc)"
  type        = string
}

variable "iam_resource_path" {
  default     = "/"
  description = "Default path for IAM policies"
  type        = string
}

variable "jwt_key_initial_value" {
  description = "JWT key initial value, should be rotated immediately"
  type        = string
}

variable "application_logs_bucket" {
  description = "Application logs bucket"
  type        = string
}

#####################
# Process Data bucket
#####################
variable "process_data_bucket_key_alias" {
  description = "Key alias for Process Data bucket"
  type        = string
}

##########
# Mu Stuff
##########
variable "mu_default_task_execution_role" {
  description = "Default task execution role for Mu processes"
  type        = string
}

variable "job_data_bucket" {
  description = "Bucket for Mu Job data (parameters and such)"
  type        = string
}

variable "job_manifest_bucket" {
  description = "Bucket for Mu Job manifests"
  type        = string
}

variable "job_manifest_kms_key_alias" {
  description = "Key alias for Mu Job manifest bucket"
  type        = string
}

variable "process_data_bucket" {
  description = "Bucket for process service data"
  type        = string
}

###################
# EKS Cluster stuff
###################
variable "cluster_name" {
  description = "Name tag to apply to EKS cluster"
  type        = string
}

variable "cluster_k8s_version" {
  description = "Version of Kubernetes / EKS to run the application on"
  type        = string
}

variable "kubernetes_external_secrets_role" {
  description = "Name of the role assumed by the 'Kubernetes External Secrets' deployment pod"
  type        = string
}

variable "ecr_cred_helper_role" {
  description = "Name of the role assumed by the 'ECR Cred Helper' CronJob pod"
  type        = string
}

variable "fluentd_role" {
  description = "Name of the role assumed by the FluentD daemonset pods"
  type        = string
}

variable "aws_alb_ingress_controller_role" {
  description = "Name of the role assumed by the 'AWS ALB Ingress Controller' Deployment pod"
  type        = string
}

variable "certmanager_role" {
  description = "Name of the role assumed by the 'CertManager' Deployment pods"
  type        = string
}

variable "redshift_role" {
  description = "Name of the role assumed by Redshift for access to S3"
  type        = string
}

###########
# VPC Stuff
###########

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "vpc_subnet_cidr_block_prefix" {
  description = "VPC Subnet CIDR block prefix"
  type        = string
}

variable "vpc_subnet_cidr_block_suffix" {
  description = "VPC Subnet CIDR block suffix"
  type        = string
}

###########
# Ingress VPC Stuff
###########

variable "ingress_vpc_cidr_block" {
  description = "Ingress VPC CIDR block"
  type        = string
}

variable "ingress_vpc_subnet_cidr_block_prefix" {
  description = "Igress VPC Subnet CIDR block prefix"
  type        = string
}

variable "ingress_vpc_subnet_cidr_block_suffix" {
  description = "Ingress VPC Subnet CIDR block suffix"
  type        = string
}

variable "enable_customer_networking" {
  description = "Enable/disable customer networking infrastrcture"
  type        = bool
}

variable "customer_networking_amis" {
  description = "AMIs to use for the customer VPN (Cisco CSR)"
  type        = map
}

variable "customer_networking_instance_type" {
  default     = "t2.medium"
  description = "Instance type for the customer VPN (Cisco CSR)"
  type        = string
}

variable "customer_networking_key_name" {
  description = "Key name for the customer VPN (Cisco CSR)"
  type        = string
}

variable "customer_networking_public_key" {
  description = "Public key for the customer VPN (Cisco CSR)"
  type        = string
}

variable "partners_vpn_secret_recovery_window_days" {
  description = "Number of days to keep rotated KMS key"
  type        = number
}

variable "partners_ingress_open_ports" {
  description = "Ports used for sending / receiving Partners traffic to Ingress Mirth"
  type        = list(string)
}

variable "cumedicine_vpn_secret_recovery_window_days" {
  description = "Number of days to keep rotated KMS key"
  type        = number
}

variable "cumedicine_ingress_open_ports" {
  description = "Ports used for sending / receiving CU Medicine traffic to Ingress Mirth"
  type        = list(string)
}

###########################
# ElastiCache (Redis) stuff
###########################
# cache.t2.medium = 2 vCPUs, 3.22 GiB
variable "elasticache_cluster_id" {
  description = "ElastiCache Redis cluster name"
  type        = string
}

variable "elasticache_rg_id" {
  description = "ElastiCache Redis replication group id"
  type        = string
}

variable "elasticache_node_type" {
  description = "Node type of elasticcache cluster"
  type        = string
  default     = "cache.t3.micro"
}

variable "elasticache_number_cache_clusters" {
  description = "Number of nodes within cluster (Needs to be >= 2 for Multi-AZ)"
  type        = string
  default     = "2"
}

variable "elasticache_password" {
  description = "Password for elasticcache cluster"
  type        = string
}

variable "firehose_lambda_function_dir" {
  description = "The path of firehose lambda function."
  type        = string
}

###################
# Worker node stuff
###################
variable "node_amis" {
  description = "AMI to use for worker nodes"
  type        = map
}

variable "node_key_name" {
  description = "Name of private key for worker nodes"
  type        = string
}

variable "node_public_key" {
  description = "AWS Public Key for the worker node keypair"
  type        = string
}

variable "node_instance_type" {
  default     = "t3a.small"
  description = "Instance type to use for worker nodes"
  type        = string
}

variable "node_asg_min_size" {
  default     = 1
  description = "Min size of ASG group for worker nodes"
  type        = number
}

variable "node_asg_max_size" {
  default     = 10
  description = "Max size of ASG group for worker nodes"
  type        = number
}

variable "node_volume_size" {
  default     = 20
  description = "EBS vol size for worker nodes"
  type        = number
}

variable "node_bootstrap_args" {
  default     = ""
  description = "Optional args to pass to worker nodes on initial startup"
  type        = string
}

variable "node_group_name" {
  description = "Name tag to apply to node ASG group"
  type        = string
}

variable "application_worker_node_instance_role" {
  description = "EKS worker node role name"
  type        = string
}

##############
# Bastion host
##############
variable "bastion_instance_type" {
  default     = "t3a.micro"
  description = "Instance type for the bastion host"
  type        = string
}

variable "bastion_amis" {
  description = "AMI to use for bastion host"
  type        = map
}

variable "bastion_host_key_name" {
  description = "AWS Key Pair name for the bastion host"
  type        = string
}

variable "bastion_host_public_key" {
  description = "AWS Public Key for the bastion host keypair"
  type        = string
}

variable "application_bastion_ingress_from_cidr_sgs" {
  description = "List of security groups rules to open the application network bastion to a list of CIDR blocks"
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "application_bastion_ingress_from_sg_sgs" {
  description = "List of security groups rules to open the application network bastion to another security group (by ID)"
  type = list(object({
    description              = string
    from_port                = string
    to_port                  = string
    protocol                 = string
    source_security_group_id = string
  }))
}

variable "ingress_bastion_ingress_from_cidr_sgs" {
  description = "List of security groups rules to open the ingress network bastion to a list of CIDR blocks"
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "ingress_bastion_ingress_from_sg_sgs" {
  description = "List of security groups rules to open the ingress network bastion to another security group (by ID)"
  type = list(object({
    description              = string
    from_port                = string
    to_port                  = string
    protocol                 = string
    source_security_group_id = string
  }))
}

############################
# Application database (RDS)
############################
variable "application_database_identifier" {
  description = "RDS resource name for the application database"
  type        = string
}

variable "application_database_name" {
  description = "Application database name"
  type        = string
}

variable "application_database_admin_username" {
  description = "Application database admin username"
  type        = string
}

variable "application_database_size" {
  default     = 10
  description = "DB vol size"
  type        = number
}

variable "application_database_version" {
  default     = "11.8"
  description = "PostgreSQL version to use for DB instance"
  type        = string
}

# db.t3.small = 1vCPUs, 1 GiB RAM
variable "application_database_instance_class" {
  default     = "db.t3.small"
  description = "RDS instance type"
  type        = string
}

variable "application_database_backup_retention_period" {
  default     = 7
  description = "Number of days to retain backups"
  type        = number
}

variable "application_database_deletion_protection" {
  type        = bool
  description = "Protect database from deletion"
  default     = true
}

variable "application_database_additional_ingress_sgs" {
  description = "List of additional SG Ids to enable for ingress to the application database"
  type        = list(string)
}

variable "application_database_enabled_cloudwatch_logs_exports" {
  default     = ["postgresql", "upgrade", "error", "slowquery"]
  description = "List of log types to export to CloudWatch logs"
  type        = list(string)
}

variable "application_database_monitoring_interval" {
  default     = 30
  description = "Interval, in seconds, that enhanced monitoring metrics will be collected"
  type        = number
}

variable "application_database_subnet_group_name" {
  description = "Subnet Group name for the Application Database"
  type        = string
}

variable "application_database_secret_recovery_window_days" {
  description = "Number of days to allow recovery of application database secrets"
  type        = number
}

variable "application_database_multi_az" {
  default     = false
  description = "Enable/disable multi_az for application database"
  type        = bool
}

###########################
# Application Secrets stuff
###########################

variable "application_secrets_kms_key_alias" {
  description = "KMS Key alias for application secrets"
  type        = string
}

variable "aws_secrets_recovery_window_in_days" {
  description = "Recovery window for AWS Secrets in days"
  type        = number
}

variable "aws_secret_manager_secret_key_initial_value" {
  description = "Initial value of AWS secret for ssh keypairs"
  type        = string
}

###########################
# SNS Topics and SQS Queues
###########################
variable "sns_topics" {
  description = "Mapping of SNS topics, e.g. { event_topic: { name: '<Topic Name>', display_name: '<Topic Display Name>' } }"
  type        = map
}

variable "sqs_queues" {
  description = "Mapping of SQS queues, e.g. { casebuilder_queue: '<Queue Name>', activitylog_queue: '<Queue Name>', munotification_queue: '<Queue Name>' }"
  type        = map
}

variable "application_sns_topic_kms_key_alias" {
  description = "KMS key alias for key used for encrypting SNS topics"
  type        = string
}

variable "application_sqs_queue_kms_key_alias" {
  description = "KMS key alias for key used for encrypting SQS queues"
  type        = string
}

#################
# Developer stuff
#################
# An array of developer objects with 'name' and 'email' properties
variable "developers" {
  default     = []
  description = "Developers for whom we are creating resources"
  type        = list
}

variable "developer_policy_arns" {
  default     = []
  description = "Policy ARNs to assign to developers"
  type        = list
}

#############
# Mirth stuff
#############
variable "mirth_role_name" {
  description = "Name of the role that the Mirth container will assume"
  type        = string
}

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
  description = "DB volume size"
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

variable "mirth_database_multi_az" {
  default     = false
  description = "Enable/disable multi_az for Mirth database"
  type        = bool
}

variable "mirth_database_subnet_group_name" {
  description = "Subnet Group name for the Mirth Database"
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

variable "application_mirthconnect_dns_address" {
  description = "DNS name for application Mirth Connect load balancer"
  type        = string
}

variable "ingress_mirth_role_name" {
  description = "Name of the role that the Ingress Mirth container will assume"
  type        = string
}

variable "ingress_mirth_database_identifier" {
  description = "RDS resource name for the ingress mirth database"
  type        = string
}

variable "ingress_mirth_database_size" {
  default     = 10
  description = "DB vol size"
  type        = number
}

# db.t3.small = 1vCPUs, 1 GiB RAM
variable "ingress_mirth_database_instance_class" {
  default     = "db.t3.small"
  description = "RDS instance type"
  type        = string
}

variable "ingress_mirth_database_multi_az" {
  default     = false
  description = "Enable/disable multi_az for Ingress Mirth database"
  type        = bool
}

variable "ingress_mirth_database_subnet_group_name" {
  description = "Subnet Group name for the Ingress Mirth database"
  type        = string
}

variable "ingress_mirth_database_secrets_usage_policy_name" {
  description = "Database secrets usage policy name for Ingress Mirth"
  type        = string
}

variable "ingress_mirth_database_kms_key_alias" {
  description = "Database KMS key alias for Ingress Mirth"
  type        = string
}

variable "ingress_mirth_database_parameter_group" {
  description = "Database parameter group name for Ingress Mirth"
  type        = string
}

variable "ingress_mirth_database_secret_name" {
  description = "Database secret name for Ingress Mirth"
  type        = string
}

variable "ingress_mirth_database_admin_secret_name" {
  description = "Database admin secret name for Ingress Mirth"
  type        = string
}

variable "ingress_mirth_database_security_group_name" {
  description = "Database security group name for Ingress Mirth"
  type        = string
}

variable "ingress_mirth_rds_enhanced_monitoring_role_name" {
  description = "Enhanced monitoring role for Ingress Mirth RDS"
  type        = string
}

variable "ingress_mirthconnect_dns_address" {
  description = "DNS name for ingress Mirth Connect load balancer"
  type        = string
}

variable "ingress_mirth_amis" {
  description = "AMIs to use for ingress mirth"
  type        = map
}

variable "ingress_mirth_key_name" {
  description = "AWS Key Pair name for ingress mirth"
  type        = string
}

variable "ingress_mirth_public_key" {
  description = "AWS Public Key for the ingress mirth keypair"
  type        = string
}

variable "ingress_mirth_instance_type" {
  default     = "t3a.small"
  description = "EC2 instance type for ingress mirth"
  type        = string
}

variable "ingress_mirth_additional_open_ports" {
  description = "Additional ports to open for Ingress Mirth"
  type        = list
}

variable "app_mirth_to_ingress_mirth_open_ports" {
  description = "The port number used by app mirth communicating to ingress mirth."
  type        = list
}

################
# Redshift Stuff
################
variable "application_data_warehouse_identifier" {
  description = "Redshift identifier"
  type        = string
}

variable "application_data_warehouse_name" {
  description = "Redshift db name"
  type        = string
}

variable "application_data_warehouse_node_type" {
  default     = "ds2.large"
  description = "Redshift data warehouse node type"
  type        = string
}

variable "application_data_warehouse_admin_username" {
  description = "Redshift admin username"
  type        = string
}

variable "application_data_warehouse_snapshot_retention_period" {
  default     = 1
  description = "Redshift snapshot retention period"
  type        = string
}

variable "application_data_warehouse_cluster_version" {
  default     = "1.0"
  description = "Redshift cluster version"
  type        = string
}

variable "application_data_warehouse_number_of_nodes" {
  default     = 1
  description = "Redshift cluster, number of nodes"
  type        = number
}

variable "application_data_warehouse_logging_prefix" {
  description = "Redshift cluster S3 log prefix"
  type        = string
}

variable "application_data_warehouse_snapshot_copy" {
  default     = {}
  description = "List of Redshift snapshot details (region, retention_period). Max length = 1"
  type        = map(string)
}

variable "application_data_warehouse_subnet_group_name" {
  description = "Redshift cluster subnet group name"
  type        = string
}

variable "application_data_warehouse_secret_recovery_window_days" {
  description = "Number of days to allow recovery of Redshift data warehouse secrets"
  type        = number
}

variable "application_data_warehouse_log_bucket_policy_aws_account" {
  description = "AWS Account which runs Redshift, which we need to give access to write to our logs bucket (https://docs.aws.amazon.com/redshift/latest/mgmt/db-auditing.html#db-auditing-logs)"
  type        = string
}

variable "application_data_warehouse_additional_ingress_sgs" {
  description = "List of additional SG Ids to enable for ingress to the application data warehouse"
  type        = list(string)
}

variable "application_data_warehouse_additional_ingress_cidr_sgs" {
  description = "List of additional SG CIDR(s) to enable for ingress to the application data warehouse"
  type        = list(string)
}

#####################
# Elasticsearch Stuff
#####################
variable "application_elasticsearch_domain" {
  description = "Elasticsearch domain"
  type        = string
}

variable "application_elasticsearch_version" {
  description = "Elasticsearch version"
  type        = string
}

variable "application_elasticsearch_ebs_volume_size" {
  default     = "10"
  description = "EBS Volume Size in Gigabytes used for storing Elasticsearch data"
  type        = string
}

variable "application_elasticsearch_instance_type" {
  default     = "t3.small.elasticsearch"
  description = "ElasticSearch service instance type"
  type        = string
}

variable "application_elasticsearch_instance_count" {
  default     = 1
  description = "ElasticSearch service instance count"
  type        = number
}

variable "application_elasticsearch_dedicated_master_enabled" {
  default     = false
  description = "ElasticSearch service use dedicated master nodes"
  type        = bool
}

variable "application_elasticsearch_zone_awareness_enabled" {
  default     = false
  description = "ElasticSearch service multi-az deployment"
  type        = bool
}

############
# WAF Stuff
############
variable "waf_regional_prefix" {
  default     = "regional"
  description = "AWS WAF name prefix"
  type        = string
}

variable "blacklisted_ips" {
  default     = []
  description = "List of ips to be blocked by WAF"
  type        = list
}

variable "admin_remote_ipset" {
  default     = []
  description = "List of ip to be blocked as remote admin"
  type        = list
}

variable "acl_constraint_body_size" {
  default     = 4096
  description = "Maximum number of bytes allowed in the body of the request. If you do not plan to allow large uploads, set it to the largest payload value that makes sense for your web application. Accepting unnecessarily large values can cause performance issues, if large payloads are used as an attack vector against your web application."
  type        = number
}

variable "acl_constraint_cookie_size" {
  default     = 4093
  description = "Maximum number of bytes allowed in the cookie header. The maximum size should be less than 4096, the size is determined by the amount of information your web application stores in cookies. If you only pass a session token via cookies, set the size to no larger than the serialized size of the session token and cookie metadata."
  type        = number
}

variable "cluster_autoscaler_service_role" {
  description = "Name of the role assumed by the 'Kubernetes Cluster Autoscaler' deployment pod"
  type        = string
}

variable "acl_constraint_query_string_size" {
  default     = 1024
  description = "Maximum number of bytes allowed in the query string component of the HTTP request. Normally the  of query string parameters following the ? in a URL is much larger than the URI , but still bounded by the  of the parameters your web application uses and their values."
  type        = number
}

variable "acl_constraint_uri_size" {
  default     = 512
  description = "Maximum number of bytes allowed in the URI component of the HTTP request. Generally the maximum possible value is determined by the server operating system (maps to file system paths), the web server software, or other middleware components. Choose a value that accomodates the largest URI segment you use in practice in your web application."
  type        = number
}

variable "web_admin_url" {
  default     = "/admin"
  description = "The url that web admin request starts with"
  type        = string
}

variable "acl_constraint_match_auth_tokens" {
  default     = ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
  description = "JSON Web Token signature portion which is  hijacked"
  type        = string
}

variable "acl_constraint_session_id" {
  default     = ""
  description = "Session id contained in cookie which is  hijacked"
  type        = string
}

#####################################
# Managed Apache Kafka Cluster (MSK)
#####################################
variable "kafka_version" {
  description = "Kafka version to be used"
  type        = string
}

variable "msk_instance_type" {
  default     = "kafka.t3.small"
  description = "Instance type of Kafka cluster"
  type        = string
}

variable "number_of_kafka_broker_nodes" {
  default     = 2
  description = "Number of broker nodes of Kafka cluster (min: 2)"
  type        = number
}

variable "msk_ebs_volume_size" {
  default     = 10
  description = "EBS volume size of Kafka cluster nodes"
  type        = number
}

variable "msk_private_subnet_cidr_block" {
  default     = []
  description = "List of cidr blocks tfor msk subnets"
  type        = list
}

variable "emr_release_label" {
  description = "Version of EMR to use"
  type        = string
}

variable "emr_instance_profile" {
  description = "IAM profile for EMR instances"
  type        = string
}

variable "emr_master_volume_type" {
  default     = "gp2"
  description = "EBS volume type"
  type        = string
}

variable "emr_master_instance_type" {
  default     = "m6g.xlarge"
  description = "EC2 instance type of EMR master instances"
  type        = string
}

variable "emr_master_instance_group_name" {
  description = "Name tag of EMR instance group"
  type        = string
}

variable "emr_core_instance_count_min" {
  default     = 1
  description = "EMR core instance count min size"
  type        = number
}

variable "emr_core_instance_count_max" {
  default     = 1
  description = "EMR core instance count max"
  type        = number
}

variable "emr_core_volume_size_in_gb" {
  description = "EMR core instance EBS vol size"
  default     = "20"
  type        = string
}

variable "emr_core_volume_type" {
  default     = "gp2"
  description = "EBS vol type to use for EMR core instances"
  type        = string
}

variable "emr_core_instance_type" {
  default     = "m6g.xlarge"
  description = "EC2 instance type of EMR core instances"
  type        = string
}

variable "emr_core_instance_group_name" {
  description = "Name tag to apply to the EMR core instance group"
  type        = string
}

variable "emr_ebs_root_volume_size" {
  default     = 20
  description = "EMR master/core instance EBS root vol size"
  type        = number
}

variable "sns_source_addresses" {
  description = "Source CIDR blocks of SNS message sources to apply to SG"
  type        = list
}

#################
# Data Lake stuff
#################
variable "emr_subnet_cidr_block" {
  description = "Subnet CIDR of subnet to place EMR instances within"
  type        = string
}

variable "kafka_avail_zone_distribution" {
  description = "The distribution of broker nodes across availability zones"
  type        = string
}

variable "kafka_enhanced_monitoring" {
  description = "Specify the desired enhanced MSK CloudWatch monitoring level"
  type        = string
}

variable "data_lake_emr_host_key_name" {
  description = "Key pair name tag for EMR instances"
  type        = string
}

variable "data_lake_emr_host_public_key" {
  description = "Public key for EMR instances"
  type        = string
}

variable "data_lake_additional_users" {
  description = "Addtional IAM users to add to data lake policy"
  type        = list(string)
}

variable "emr_spark_certs_file_path" {
  description = "Zip of ssl certs for EMR clusters"
  type        = string
}

###############################
# Security Tools related
###############################
variable "aws_inspector_enabled" {
  default     = true
  description = "Set to false to disable all resources in this module."
}

variable "inspector_enable_scheduled_event" {
  description = "Enable Cloudwatch Events to schedule an assessment"
  type        = bool
}

variable "inspector_schedule_expression" {
  description = "AWS Schedule Expression: https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  type        = string
}

variable "inspector_assessment_duration" {
  description = "The duration of the Inspector assessment run"
  type        = string
}

variable "ruleset_cve" {
  description = "Enable Common Vulnerabilities and Exposures Ruleset"
  type        = bool
}

variable "ruleset_cis" {
  description = "Enable CIS Operating System Security Configuration Benchmarks Ruleset"
  type        = bool
}

variable "aws_inspector_ruleset_region" {
  description = "AWS publish inspector rules in every region , but we pick us-east-1"
  type        = string
}

variable "aws_ruleset_account_id" {
  description = "AWS account id in which inspector rules are published"
  type        = string
}

variable "aws_ruleset_cve_id" {
  description = "Inspector ruleset ID (region specific)"
  type        = string
}

variable "aws_ruleset_cis_id" {
  description = "Inspector CIS ruleset ID (region specific)"
  type        = string
}

variable "ruleset_security_best_practices_id" {
  description = "Inspector security best practices ID (region specific)"
  type        = string
}

variable "ruleset_network_reachability_id" {
  description = "Inspector network rechability ruleset ID (region specific)"
  type        = string
}

variable "ruleset_security_best_practices" {
  description = "Enable AWS Security Best Practices Ruleset (region specific)"
  type        = bool
}

variable "ruleset_network_reachability" {
  description = "Enable AWS Network Reachability Ruleset"
  type        = bool
}

variable "guardduty_detector_enable" {
  description = "Enable monitoring and feedback reporting"
  type        = bool
}

variable "guardduty_master_account_id" {
  description = "Account ID for Guard Duty Master. Required if is_guardduty_member"
  type        = string
}

variable "app_vpc_flow_log_group_name" {
  description = "VPC Flow Log group name"
  type        = string
}

variable "app_vpc_flow_log_traffic_type" {
  description = "VPC Flow Log traffic type to capture"
  type        = string
}

variable "ingress_vpc_flow_log_group_name" {
  description = "Ingress VPC Flow Log group name"
  type        = string
}

variable "ingress_vpc_flow_log_traffic_type" {
  description = "Ingress VPC Flow Log traffic type to capture"
  type        = string
}

variable "emr_bootstrap_action_name" {
  description = "EMR spark cluster bootstrap action name"
  type        = string
}

variable "emr_bootstrap_script_file_path" {
  description = "EMR spark cluster bootstrap script file path"
  type        = string
}

variable "aws_foundations_securityhub_standards_subscription_arn" {
  description = "ARN of AWS secutiryhub standards sybscription"
  type        = string
}

variable "aws_securityhub_product_subscription_arn" {
  description = "ARN of AWS secutiryhub product subscription (region specific)"
  type        = string
}

variable "new_relic_temporary_license_key" {
  description = "Temporary new relic license key"
  type        = string
}

variable "cloud_watch_ingest_to_elasticsearch_log_groups" {
  description = "The map containing name, arn, shard_count of log group of the services to ingest to Elastic Search."
  type        = map(map(string))
}

variable "firehose_lambda_runtime_type" {
  description = "The runtime virtual machine used to execute  lambda function of Firehose record transformation."
  type        = string
}

variable "firehose_lambda_function_timeout" {
  description = "The amount of time the Lambda Function has to run in seconds. Defaults to 3."
  type        = number
}

variable "firehose_cloudwatch_log_retention" {
  description = "The number of days the log events are retained in the specified log group."
  type        = number
}

variable "kinesis_rentention_period" {
  description = "Length of time data records are accessible after they are added to the stream. The maximum value of a stream's retention period is 168 hours. Minimum value is 24. Default is 24."
  type        = number
}

variable "log_subscription_filter_distribution" {
  description = "The method used to distribute log data to the destination."
  type        = string
}

variable "firehose_elasticsearch_configuration_buffering_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds between 60 to 900."
  type        = number
}

variable "firehose_elasticsearch_configuration_buffering_size" {
  description = "Buffer incoming data to the specified size, in MBs between 1 to 100, before delivering it to the destination."
  type        = number
}

variable "firehose_s3_backup_bucket_configuration_buffering_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300."
  type        = number
}

variable "firehose_s3_backup_bucket_configuration_buffering_size" {
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5."
  type        = number
}

variable "firehose_s3_backup_bucket_configuration_prefix" {
  description = "An extra prefix to be added in front of the time format prefix. The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files."
  type        = string
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
  description = "Defines how documents should be delivered to Amazon S3. Valid values are FailedDocumentsOnly and AllDocuments. Default value is FailedDocumentsOnly. "
  type        = string
}

variable "firehose_elasticsearch_configuration_index_rotation_period" {
  description = "The Elasticsearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data."
  type        = string
}

variable "firehose_record_lambda_func_processing_configuration_enabled" {
  description = "Enables or disables data processing."
  type        = bool
}

variable "firehose_record_processors_type" {
  description = "The type of processor. Valid Values: Lambda"
  type        = string
}

variable "firehose_processor_parameter_name" {
  description = "Parameter name. Valid Values: LambdaArn, NumberOfRetries, RoleArn, BufferSizeInMBs, BufferIntervalInSeconds. "
  type        = string
}

variable "kinesis_stream_kms_key_alias" {
  description = "Alias of the GUID for the customer-managed KMS key to use for encryption. "
  type        = string
}

####################
#  CloudWatch Alarms
####################
variable "free_storage_metrix_name" {
  description = "The name for the free storage space alarm's associated metric. "
  type        = string
}

variable "percentage_disk_space_used_metrix_name" {
  description = "The name for the percentage disk used alarm's associated metric. "
  type        = string
}

variable "less_than_or_equal_to_comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold: LessThanOrEqualToThreshold."
  type        = string
}

variable "greater_than_comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold: GreaterThanThreshold."
  type        = string
}
variable "statistic_period" {
  description = "The period in seconds over which the specified statistic is applied. "
  type        = string
}

variable "treat_missing_data" {
  description = "Sets how this alarm is to handle missing data points as ignore"
  type        = map(string)
}

variable "cloudwatch_alarm_namespace" {
  description = "The namespace for the alarm's associated metric. "
  type        = map(string)
}

variable "low_storage_space_cloudwatch_alarm" {
  description = "The map containing db_identifier,  other parameters of a database low free storage space alarm."
  type        = map(map(map(string)))
}

variable "ingress_mirth_alarms_enabled" {
  default     = false
  description = "Enable/Disable Ingress Mirth liveness and net throughput alarms"
  type        = bool
}

variable "ingress_mirth_liveness_threshold" {
  default     = 0
  description = "Expected 'StatusCheckFailed' count for alerting on Ingress Mirth liveness"
  type        = number
}

variable "ingress_mirth_network_throughput_threshold" {
  default     = 0
  description = "Minimum network throughput threshold for alerting on Ingress Mirth liveness"
  type        = number
}

variable "customer_networking_csr_1_liveness_threshold" {
  default     = 0
  description = "Expected 'StatusCheckFailed' count for alerting on the Customer Networking CSR 1 liveness"
  type        = number
}

variable "customer_networking_csr_1_network_throughput_threshold" {
  default     = 0
  description = "Minimum network throughput threshold for alerting on Customer Networking CSR 1 liveness"
  type        = number
}

variable "activitylog_queue_alarm_count_threshold" {
  description = "Minimum queue size threshold for alerting on the Activity Log SQS queue"
  type        = number
}
variable "activitylog_queue_alarm_minutes" {
  description = "Number of minutes that the Activity Log SQS queue must be at minimum queue size threshold to alarm"
  type        = number
}

variable "casebuilder_queue_alarm_count_threshold" {
  description = "Minimum queue size threshold for alerting on the Case Builder SQS queue"
  type        = number
}
variable "casebuilder_queue_alarm_minutes" {
  description = "Number of minutes that the Case Builder SQS queue must be at minimum queue size threshold to alarm"
  type        = number
}

variable "casebuilder_deadletter_queue_alarm_count_threshold" {
  description = "Minimum queue size threshold for alerting on the Case Builder Dead Letter SQS queue"
  type        = number
}
variable "casebuilder_deadletter_queue_alarm_minutes" {
  type        = number
  description = "Number of minutes that the Case Builder Dead Letter SQS queue must be at minimum queue size threshold to alarm"
}

variable "caseevents_queue_alarm_count_threshold" {
  description = "Minimum queue size threshold for alerting on the Case Events SQS queue"
  type        = number
}
variable "caseevents_queue_alarm_minutes" {
  description = "Number of minutes that the Case Events SQS queue must be at minimum queue size threshold to alarm"
  type        = number
}

variable "caseevents_deadletter_queue_alarm_count_threshold" {
  description = "Minimum queue size threshold for alerting on the Case Events Dead Letter SQS queue"
  type        = number
}
variable "caseevents_deadletter_queue_alarm_minutes" {
  description = "Number of minutes that the Case Events Dead Letter SQS queue must be at minimum queue size threshold to alarm"
  type        = number
}

variable "charge_processor_queue_alarm_count_threshold" {
  description = "Minimum queue size threshold for alerting on the Charge Processor SQS queue"
  type        = number
}
variable "charge_processor_queue_alarm_minutes" {
  description = "Number of minutes that the Charge Processor SQS queue must be at minimum queue size threshold to alarm"
  type        = number
}

variable "charge_processor_deadletter_queue_alarm_count_threshold" {
  description = "Minimum queue size threshold for alerting on the Charge Processor Dead Letter SQS queue"
  type        = number
}
variable "charge_processor_deadletter_queue_alarm_minutes" {
  description = "Number of minutes that the Charge Processor Dead Letter SQS queue must be at minimum queue size threshold to alarm"
  type        = number
}

variable "externaltaskmonitor_queue_alarm_count_threshold" {
  description = "Minimum queue size threshold for alerting on the External Task Monitor SQS queue"
  type        = number
}
variable "externaltaskmonitor_queue_alarm_minutes" {
  description = "Number of minutes that the External Task Monitor SQS queue must be at minimum queue size threshold to alarm"
  type        = number
}

variable "munotification_queue_alarm_count_threshold" {
  description = "Minimum queue size threshold for alerting on the Mu Notification SQS queue"
  type        = number
}
variable "munotification_queue_alarm_minutes" {
  description = "Number of minutes that the Mu Notification SQS queue must be at minimum queue size threshold to alarm"
  type        = number
}

variable "datawarehouse_msk_broker_disk_use_threshold" {
  default     = 75
  description = ""
  type        = number
}

########################
#  AWS KMS key rotation
########################
variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
}

#############################################################
# Application cmx-automate-ingress (external) K8S Ingress/ALB
#############################################################
variable "cmx_automate_ingress_from_cidr_sgs" {
  description = "List of security groups rules to open the cmx-automate-ingress to a list of CIDR blocks"
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "cmx_automate_ingress_from_sg_sgs" {
  description = "List of security groups rules to open the cmx-automate-ingress to another security group (by ID)"
  type = list(object({
    description              = string
    from_port                = string
    to_port                  = string
    protocol                 = string
    source_security_group_id = string
  }))
}

#############################################
# Application cmx-api-ingress K8S Ingress/ALB
#############################################
variable "application_cmx_api_ingress_from_cidr_sgs" {
  description = "List of security groups rules to open the cmx-api-ingress to a list of CIDR blocks"
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "application_cmx_api_ingress_from_sg_sgs" {
  description = "List of security groups rules to open the cmx-api-ingress to another security group (by ID)"
  type = list(object({
    description              = string
    from_port                = string
    to_port                  = string
    protocol                 = string
    source_security_group_id = string
  }))
}

###########################################################
# Application cmx-mirth-connect-api-ingress K8S Ingress/ALB
###########################################################
variable "application_mirth_connect_api_ingress_from_cidr_sgs" {
  description = "List of security groups rules to open the cmx-mirth-connect-api-ingress to a list of CIDR blocks"
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "application_mirth_connect_api_ingress_from_sg_sgs" {
  description = "List of security groups rules to open the cmx-mirth-connect-api-ingress to another security group (by ID)"
  type = list(object({
    description              = string
    from_port                = string
    to_port                  = string
    protocol                 = string
    source_security_group_id = string
  }))
}

#######################################################
# Ingress cmx-mirth-connect-api-ingress K8S Ingress/ALB
#######################################################
variable "ingress_mirth_connect_api_ingress_from_cidr_sgs" {
  description = "List of security groups rules to open the cmx-mirth-connect-api-ingress to a list of CIDR blocks"
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "ingress_mirth_connect_api_ingress_from_sg_sgs" {
  description = "List of security groups rules to open the cmx-mirth-connect-api-ingress to another security group (by ID)"
  type = list(object({
    description              = string
    from_port                = string
    to_port                  = string
    protocol                 = string
    source_security_group_id = string
  }))
}

variable "elasticsearch_index_rotation" {
  description = "Parameter for rotating indices application of Elasticsearch cluster."
  type        = map
}

variable "elasticsearch_index_rotation_lambda" {
  description = "Parameters of lambda function of rotating indices for application of Elasticsearch cluster."
  type        = map
}

####################
# S3 Lifecycle Rules
####################
variable "s3_lifecycle_incomplete_upload_days" {
  type        = number
  description = "Number of days before incomplete S3 uploads are cleaned up"
  default     = 7
}

variable "s3_lifecycle_logs_expiration_days" {
  type        = number
  description = "Number of days to keep log files in S3"
  default     = 720
}

variable "s3_lifecycle_old_version_expiration_days" {
  type        = number
  description = "Number of days before old S3 object versions are cleaned up"
  default     = 180
}

variable "s3_lifecycle_intelligent_tiering_days" {
  type        = number
  description = "Number of days before moving S3 objects to Intelligent Tiering"
  default     = 30
}
