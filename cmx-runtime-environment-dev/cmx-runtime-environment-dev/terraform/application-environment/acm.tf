// Disabling app and static certificates
/*
resource "aws_acm_certificate" "application_static_certificate" {
  domain_name       = var.application_static_dns_address
  validation_method = "DNS"

  tags = merge(
    var.shared_resource_tags,
    {
      Type         = "application_static_certificate"
      Name         = "CodaMetrix Application ACM - application_static_certificate"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "application_static_certificate_validation_record" {
  name    = "${aws_acm_certificate.application_static_certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.application_static_certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.application_zone.zone_id}"
  records = ["${aws_acm_certificate.application_static_certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "application_static_certificate_validation" {
  certificate_arn = "${aws_acm_certificate.application_static_certificate.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.application_static_certificate_validation_record.fqdn}"
  ]
}

resource "aws_acm_certificate" "application_api_certificate" {
  domain_name       = var.application_api_dns_address
  validation_method = "DNS"

  tags = merge(
    var.shared_resource_tags,
    {
      Type         = "application_api_certificate"
      Name         = "CodaMetrix Application ACM - application_api_certificate"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "application_api_certificate_validation_record" {
  name    = "${aws_acm_certificate.application_api_certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.application_api_certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.application_zone.zone_id}"
  records = ["${aws_acm_certificate.application_api_certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "application_api_certificate_validation" {
  certificate_arn = "${aws_acm_certificate.application_api_certificate.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.application_api_certificate_validation_record.fqdn}"
  ]
}
*/

resource "aws_acm_certificate" "cmx_automate_certificate" {
  domain_name       = var.cmx_automate_dns_name
  validation_method = "DNS"

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "cmx_automate_certificate"
      Name = "CodaMetrix Application ACM - cmx_automate_certificate"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cmx_automate_certificate_validation_record" {
  for_each = {
    for dvo in
    aws_acm_certificate.cmx_automate_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.cmx_automate_zone.zone_id
}

resource "aws_acm_certificate_validation" "cmx_automate_certificate_validation" {
  certificate_arn = aws_acm_certificate.cmx_automate_certificate.arn
  validation_record_fqdns = [for record
  in aws_route53_record.cmx_automate_certificate_validation_record : record.fqdn]
}

resource "aws_acm_certificate" "application_www_certificate" {
  domain_name       = var.application_www_dns_address
  validation_method = "DNS"

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_www_certificate"
      Name = "CodaMetrix Application ACM - application_www_certificate"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "application_www_certificate_validation_record" {
  for_each = {
    for dvo in
    aws_acm_certificate.application_www_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.application_zone.zone_id
}

resource "aws_acm_certificate_validation" "application_www_certificate_validation" {
  certificate_arn = aws_acm_certificate.application_www_certificate.arn
  validation_record_fqdns = [for record
  in aws_route53_record.application_www_certificate_validation_record : record.fqdn]
}

resource "aws_acm_certificate" "application_mirthconnect_certificate" {
  domain_name       = var.application_mirthconnect_dns_address
  validation_method = "DNS"

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_mirthconnect_certificate"
      Name = "CodaMetrix Application ACM - application_mirthconnect_certificate"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "application_mirthconnect_certificate_validation_record" {
  for_each = {
    for dvo in
    aws_acm_certificate.application_mirthconnect_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.application_zone.zone_id
}

resource "aws_acm_certificate_validation" "application_mirthconnect_certificate_validation" {
  certificate_arn = aws_acm_certificate.application_mirthconnect_certificate.arn
  validation_record_fqdns = [for record
  in aws_route53_record.application_mirthconnect_certificate_validation_record : record.fqdn]
}

resource "aws_acm_certificate" "ingress_mirthconnect_certificate" {
  domain_name       = var.ingress_mirthconnect_dns_address
  validation_method = "DNS"

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_mirthconnect_certificate"
      Name = "CodaMetrix Application ACM - ingress_mirthconnect_certificate"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "ingress_mirthconnect_certificate_validation_record" {
  for_each = {
    for dvo in
    aws_acm_certificate.ingress_mirthconnect_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.application_zone.zone_id
}

resource "aws_acm_certificate_validation" "ingress_mirthconnect_certificate_validation" {
  certificate_arn = aws_acm_certificate.ingress_mirthconnect_certificate.arn
  validation_record_fqdns = [for record
  in aws_route53_record.ingress_mirthconnect_certificate_validation_record : record.fqdn]
}
