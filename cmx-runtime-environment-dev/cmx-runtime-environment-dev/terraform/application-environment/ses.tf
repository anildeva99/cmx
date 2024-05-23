

# CMX SES Domain Identity
resource "aws_ses_domain_identity" "codametrix_domain_identity" {
  domain = "${var.environment}.application.codametrix.com"
}

# Policy Document Giving AWS Services Access to SES
data "aws_iam_policy_document" "codametrix_ses_policy" {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = ["${aws_ses_domain_identity.codametrix_domain_identity.arn}"]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

# Set SES Identity Policy
resource "aws_ses_identity_policy" "codametrix_ses_identity_policy" {
  identity = aws_ses_domain_identity.codametrix_domain_identity.arn
  name     = "CodaMetrixApplication-${var.environment}-codametrix_ses_identity_policy"
  policy   = data.aws_iam_policy_document.codametrix_ses_policy.json
}
