# Environment name. Something like 'sandbox', 'development', etc.
variable "environment" {
  type        = string
  description = "Environment name (sandbox, development, etc.)"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "foreign_accounts" {
  type        = list(string)
  description = "Other accounts that should be given access to ECR repos"
}

variable "ecr_repos" {
  type        = list(string)
  description = "ECR repositories that access will be given to"
}

variable "kms_keys" {
  type        = list(object({
                      key_alias = string
                      key_operations = list(string)
                   }))
  description = "Encrypted S3 Buckets which access will be given to."
}

variable "iam_resource_path" {
  type      = string
  default   = "/"
}
