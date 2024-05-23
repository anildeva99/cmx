data "template_file" "user_name" {
  count    = length(var.engineers)
  template = "$${engineer_email}-$${environment}"
  vars = {
    engineer_email = "${element(var.engineers, count.index).email}"
    environment     = var.environment
  }
}

################################
# engineer role, for SSO access
################################
resource "aws_iam_role" "engineer_role" {
  name                  = "CMXTrafficCop-${var.environment}-engineer_role"
  assume_role_policy    = var.sso_assume_role_policy_document_json
  path                  = var.iam_resource_path
  description           = "This role gives engineer access to the individual who assumes it"

  # 8 hours
  max_session_duration  = 28800

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Traffic Cop IAM - engineer_role"
      Type = "engineer_role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "engineer_role_access_policy_attachments" {
  count      = length(var.engineer_policy_arns)
  role       = aws_iam_role.engineer_role.name
  policy_arn = element(var.engineer_policy_arns, count.index)
}
