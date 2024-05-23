# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_user_pool" "application_kibana_pool" {
#   name = "CMXApp-${var.environment}-app-kibana-pool"
#   tags = merge(
#     var.shared_resource_tags,
#     {
#       Type = "application_kibana_pool"
#       Name = "CodaMetrix Application Cognito User Pool- application_kibana_pool"
#     }
#   )
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_user_pool" "ingress_kibana_pool" {
#   name = "CMXApp-${var.environment}-ingress-kibana-pool"
#   tags = merge(
#     var.shared_resource_tags,
#     {
#       Type = "ingress_kibana_pool"
#       Name = "CodaMetrix Application Cognito User Pool- ingress_kibana_pool"
#     }
#   )
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_user_pool_domain" "application_kibana_domain" {
#   domain       = "cmxapp-${var.environment}-kibana-elasticsearch"
#   user_pool_id = aws_cognito_user_pool.application_kibana_pool.id
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_user_pool_domain" "ingress_kibana_domain" {
#   domain       = "cmxapp-${var.environment}-ingress-kibana-elasticsearch"
#   user_pool_id = aws_cognito_user_pool.ingress_kibana_pool.id
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_user_group" "app_logs" {
#   name         = "CMXApp-${var.environment}-es-app-logs"
#   user_pool_id = aws_cognito_user_pool.application_kibana_pool.id
#   description  = "Allow access to application logs"
#   precedence   = 100
#   role_arn     = aws_iam_role.app_user_poolauth_role.arn
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_user_group" "ingress_logs" {
#   name         = "CMXApp-${var.environment}-es-ingress-logs"
#   user_pool_id = aws_cognito_user_pool.ingress_kibana_pool.id
#   description  = "Allow access to all  ingress logs"
#   precedence   = 10
#   role_arn     = aws_iam_role.ingress_user_poolauth_role.arn
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_identity_pool" "application_kibana_identity" {
#   # dash line in name is not allowed
#   identity_pool_name               = "CMXApp_${var.environment}_app_kibana_identity"
#   allow_unauthenticated_identities = false
#
#   # !!! These app clients are causing problems. ES creates it's own app client, what we need to do is
#   # !!! use that app client and update it after the fact to modify that app client to use our own identity provider
#   # !!! See: https://github.com/terraform-providers/terraform-provider-aws/issues/5557
#   #cognito_identity_providers {
#   #  client_id = aws_cognito_user_pool_client.cmx_app_client.id
#   #  provider_name           = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.application_kibana_pool.id}"
#   #  server_side_token_check = true
#   #}
#
#   tags = merge(
#     var.shared_resource_tags,
#     {
#       Type = "application_kibana_identity"
#       Name = "CodaMetrix Application Cognito User Pool- application_kibana_identity"
#     }
#   )
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_identity_pool" "ingress_kibana_identity" {
#   # dash line in name is not allowed
#   identity_pool_name               = "CMXApp_${var.environment}_ingress_kibana_identity"
#   allow_unauthenticated_identities = false
#
#   # !!! These app clients are causing problems. ES creates it's own app client, what we need to do is
#   # !!! use that app client and update it after the fact to modify that app client to use our own identity provider
#   # !!! See: https://github.com/terraform-providers/terraform-provider-aws/issues/5557
#   #cognito_identity_providers {
#   #  client_id = aws_cognito_user_pool_client.cmx_ingress_client.id
#   #  provider_name           = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.ingress_kibana_pool.id}"
#   #  server_side_token_check = false
#   #}
#
#   tags = merge(
#     var.shared_resource_tags,
#     {
#       Type = "ingress_kibana_identity"
#       Name = "CodaMetrix Application Cognito User Pool- ingress_kibana_identity"
#     }
#   )
# }

# !!! These app clients are causing problems. ES creates it's own app client, what we need to do is
# !!! use that app client and update it after the fact to modify that app client to use our own identity provider
# !!! See: https://github.com/terraform-providers/terraform-provider-aws/issues/5557
#resource "aws_cognito_user_pool_client" "cmx_app_client" {
#  name                = "CMXApp-${var.environment}-application-client"
#  user_pool_id        = aws_cognito_user_pool.application_kibana_pool.id
#  generate_secret     = true
#  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
#  callback_urls       = [ "https://${aws_elasticsearch_domain.application_elasticsearch_domain.kibana_endpoint}" ]
#  logout_urls         = [ "https://${aws_elasticsearch_domain.application_elasticsearch_domain.kibana_endpoint}" ]
#}


# !!! These app clients are causing problems. ES creates it's own app client, what we need to do is
# !!! use that app client and update it after the fact to modify that app client to use our own identity provider
# !!! See: https://github.com/terraform-providers/terraform-provider-aws/issues/5557
#resource "aws_cognito_user_pool_client" "cmx_ingress_client" {
#  name                = "CMXApp-${var.environment}-ingress-client"
#  user_pool_id        = aws_cognito_user_pool.ingress_kibana_pool.id
#  generate_secret     = true
#  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
#}

# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_identity_pool_roles_attachment" "kibana_identity" {
#   identity_pool_id = aws_cognito_identity_pool.application_kibana_identity.id
#   roles = {
#     "authenticated"   = "${aws_iam_role.app_user_poolauth_role.arn}",
#     "unauthenticated" = "${aws_iam_role.app_user_poolunauth_role.arn}"
#   }
# }

# !!! Disabling elasticsearch authentication for now...
# resource "aws_cognito_identity_pool_roles_attachment" "ingress_kibana_identity_attach" {
#   identity_pool_id = aws_cognito_identity_pool.ingress_kibana_identity.id
#   roles = {
#     "authenticated"   = "${aws_iam_role.ingress_user_poolauth_role.arn}",
#     "unauthenticated" = "${aws_iam_role.ingress_user_poolunauth_role.arn}"
#   }
# }
