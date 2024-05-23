variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Something like 'sandbox', 'dev', etc.
variable "environment" {
  type        = string
  description = "Environment name (sandbox, dev, etc.)"
}

variable "shared_resource_tags" {
  type = map
}

variable "iam_resource_path" {
  type    = string
  default = "/"
}

variable "sso_assume_role_policy_document_json" {
  type          = string
  description   = "Policy document that enables roles associated to be assumed from the SSO login account"
}

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
