# Default provider
provider "aws" {
  region = var.aws_region
}

# Alternate provider needed for access mu_job_manifest_key
# which is in the cmxtools account
provider "aws" {
  alias  = "tools"
  region = "us-east-1"
}

# Alternate provider needed for access sagemaker_data_key
# which is within the cmxdevelopment account
provider "aws" {
  alias  = "development"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
