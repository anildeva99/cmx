# Default provider targets aws_src_region
provider "aws" {
  alias  = "source"
  region = var.aws_src_region
}

# Seconday provider targets aws_dst_region
provider "aws" {
  alias  = "dest"
  region = var.aws_dest_region
}

module "create_backup_vault" {
  source               = "./modules/create-backup-vault"
  aws_dst_region       = var.aws_dst_region
  aws_src_region       = var.aws_src_region
  enable_key_rotation  = var.enable_key_rotation
  environment          = var.environment
  shared_resource_tags = var.shared_resource_tags
  providers = {
    aws.src = aws.source
    aws.dst = aws.dest
  }
}

module "create_backup_plan" {
  source                = "./modules/create-backup-plan"
  aws_dst_region        = var.aws_dst_region
  aws_src_region        = var.aws_src_region
  dst_region_vault_arn  = module.create_backup_vault.dst_region_vault_arn
  environment           = var.environment
  shared_resource_tags  = var.shared_resource_tags
  src_region_vault_name = module.create_backup_vault.src_region_vault_name
  target_resources_arns = var.target_resources_arns
  providers = {
    aws.src = aws.source
    aws.dst = aws.dest
  }
}
