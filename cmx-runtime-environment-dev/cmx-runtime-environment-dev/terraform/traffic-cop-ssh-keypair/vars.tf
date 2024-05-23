
# Common tags applied to all resources
variable "shared_resource_tags" {
  type = map
}

variable "environment" {
  default     = "sandbox"
  type        = string
  description = "Environment name (tc1, tc2, etc.)"
}

# AWS Region
variable "aws_region" {
  type    = string
  default = "us-east-1"
}


variable "aws_secret_manager_secret_key_initial_value" {
  type = string
}

variable "aws_secrets_recovery_window_in_days" {
  type        = number
  description = "Number of days to allow recovery of secrets"
}

variable "aws_secret_bastion_host_ubuntu_private_key" {
  type = string
}

variable "aws_secret_customerrouter_private_key" {
  type = string
}

variable "aws_secret_bastion_host_bastion_private_key" {
  type = string
}

variable "aws_secret_mirth_ubuntu_private_key" {
  type = string
}

########################
#  AWS KMS key rotation
########################
variable "enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled"
}
