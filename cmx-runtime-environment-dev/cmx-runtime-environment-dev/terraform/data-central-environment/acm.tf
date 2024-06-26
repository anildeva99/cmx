###############
# Dundas Cert
###############
resource "aws_acm_certificate" "dundas_alb_certificate" {
  domain_name       = aws_route53_record.dundas_dns.name
  validation_method = "DNS"

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "dundas_alb_certificate"
      Name = "CodaMetrix Data Central ACM - dundas_alb_certificate"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "dundas_alb_certificate_validation_record" {
  for_each = {
    for dvo in
    aws_acm_certificate.dundas_alb_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.environment_zone.zone_id
}

resource "aws_acm_certificate_validation" "dundas_alb_certificate_validation" {
  certificate_arn = aws_acm_certificate.dundas_alb_certificate.arn
  validation_record_fqdns = [for record
  in aws_route53_record.dundas_alb_certificate_validation_record : record.fqdn]
}
