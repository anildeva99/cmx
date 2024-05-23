variable "aws_dst_region" {
  default     = "us-west-2"
  description = "The destination region in which to copy backups too"
  type        = string
}

variable "aws_src_region" {
  default     = "us-east-1"
  description = "The source region in which target_resource_arn exists"
  type        = string
}

variable "enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled"
}

variable "environment" {
  default     = "sandbox"
  description = "Environment name (sandbox, development, etc.)"
  type        = string
}

variable "shared_resource_tags" {
  description = "Common tags to apply to all resources"
  type        = map
}
