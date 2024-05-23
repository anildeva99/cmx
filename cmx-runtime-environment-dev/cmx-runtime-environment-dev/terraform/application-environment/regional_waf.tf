module "regional_waf" {
  source                                = "./modules/acl_regional"
  shared_resource_tags                  = var.shared_resource_tags
  waf_prefix                            = var.waf_regional_prefix
  blacklisted_ips                       = var.blacklisted_ips
  admin_remote_ipset                    = var.admin_remote_ipset
  environment                           = var.environment
  acl_constraint_body_size              = var.acl_constraint_body_size
  acl_constraint_cookie_size            = var.acl_constraint_cookie_size
  acl_constraint_query_string_size      = var.acl_constraint_query_string_size
  acl_constraint_uri_size               = var.acl_constraint_uri_size
  acl_constraint_match_auth_tokens      = var.acl_constraint_match_auth_tokens
  acl_constraint_session_id             = var.acl_constraint_session_id
}

output "regional_web_acl_id" {
  value = module.regional_waf.regional_web_acl_id
}
