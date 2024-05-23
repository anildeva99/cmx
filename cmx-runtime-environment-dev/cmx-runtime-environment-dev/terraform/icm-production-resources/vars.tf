# Also request input for an environment name. Something like 'sandbox', 'dev', etc.
variable "environment" {
  type        = string
  description = "Environment name (sandbox, dev, etc.)"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "mfa_policy_arn" {
  type        = string
  description = "ARN of the MFA policy to assign to users"
}

variable "shared_resource_tags" {
  type = map
}

# An array of user names e.g. ["huckleberry-hound","bugs-bunny"]
variable "icm_production_users" {
  type        = list
  description = "Names of the user for whom we are creating resources"
}

# An array of user names e.g. { "huckleberry-hound" = "huck@codametrix.com", "bugs-bunny" = "bugs@codametrix.com" }
variable "icm_production_user_email_map" {
  type        = map
  description = "Mapping of ICM production users to their respective emails"
}

# An array of user names e.g. ["huckleberry-hound","bugs-bunny"]
variable "cold_archive_users" {
  type        = list
  description = "Users with read/write access to the cold archive buckets"
}

# An array of user names e.g. ["huckleberry-hound","bugs-bunny"]
variable "schema_bucket_users" {
  type        = list
  description = "Users with read/write access to the schema bucket"
}

variable "iam_access_policy_prefix" {
  type    = string
  default = "icm-prod-access-policy"
}

variable "iam_resource_path" {
  type    = string
  default = "/codametrix/icm-production-resources/"
}

variable "schema_bucket_arn" {
  type          = string
  description   = "ARN of the Schema bucket (in the 'voba' account)"
}

########################
#  AWS KMS key rotation
########################
variable "enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled"
}
