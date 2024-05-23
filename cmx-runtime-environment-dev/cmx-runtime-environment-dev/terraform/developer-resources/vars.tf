# An map of developer names to email addresses
variable "developers" {
  type        = map
  description = "Map of the names of the developers for whom we are creating resources, to their email address"
}

# Also request input for an environment name. Something like 'sandbox', 'dev', etc.
variable "environment" {
  type        = string
  description = "Environment name (sandbox, dev, etc.)"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "s3_bucket_prefix" {
  type    = string
  default = "dev-bucket"
}

variable "sqs_queue_prefix" {
  type    = string
  default = "dev-queue"
}

variable "sns_topic_prefix" {
  type    = string
  default = "dev-topic"
}

variable "iam_access_policy_prefix" {
  type    = string
  default = "dev-access-policy"
}

variable "iam_resource_path" {
  type    = string
  default = "/codametrix/developer-resources/"
}

########################
#  AWS KMS key rotation
########################
variable "enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled"
}

