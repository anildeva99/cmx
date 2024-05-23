module "engineers" {
  source                                = "./modules/engineers"
  aws_region                            = var.aws_region
  environment                           = var.environment
  iam_resource_path                     = var.iam_resource_path
  shared_resource_tags                  = var.shared_resource_tags
  sso_assume_role_policy_document_json  = data.aws_iam_policy_document.sso_assume_role_policy_document.json

  engineers                            = var.engineers
  engineer_policy_arns = [
    data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn,
    aws_iam_policy.engineers_s3_access_policy.arn,
  ]
}
