resource "aws_route53_zone" "environment_zone" {
  name          = var.environment_dns_name
  force_destroy = false

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_zone"
      Name = "CodaMetrix Data Central Route 53 - environment_zone"
    }
  )
}

resource "aws_route53_record" "bastion_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "bastion.${var.environment_dns_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bastion_host.private_ip}"]
}

resource "aws_route53_record" "dundas_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "dundas.${var.environment_dns_name}"
  type    = "A"

  alias {
    name                   = aws_alb.dundas_alb.dns_name
    zone_id                = aws_alb.dundas_alb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "codametrix_ses_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "_amazonses.${var.environment_dns_name}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.codametrix_domain_identity.verification_token}"]
}

resource "aws_route53_record" "dundas_application_database_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "dundas-database.${var.environment_dns_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.dundas_application_database.address}"]
}

resource "aws_route53_record" "dundas_warehouse_database_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "dundas-warehouse.${var.environment_dns_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.dundas_warehouse_database.address}"]
}
