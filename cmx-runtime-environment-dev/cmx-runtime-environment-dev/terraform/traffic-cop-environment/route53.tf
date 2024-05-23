# Used for environment-level DNS names
resource "aws_route53_zone" "environment_zone" {
  name          = "${var.environment}.trafficcop.codametrix.com"
  force_destroy = false

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_zone"
      Name = "CodaMetrix Traffic Cop Route 53 - environment_zone"
    }
  )
}

resource "aws_route53_record" "bastion_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "bastion.${var.environment}.trafficcop.codametrix.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bastion_host.private_ip}"]
}

resource "aws_route53_record" "mirth_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = var.mirthconnect_dns_address
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.mirth.private_ip}"]
}

resource "aws_route53_record" "mirth_database_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "mirth-database.${var.environment}.trafficcop.codametrix.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.mirth.mirth_database_address}"]
}

resource "aws_route53_record" "elasticsearch_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "elasticsearch.${var.environment}.trafficcop.codametrix.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elasticsearch_domain.elasticsearch_domain.endpoint}"]
}

resource "aws_route53_record" "customerrouter_1_private_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "customerrouter-1-private.${var.environment}.trafficcop.codametrix.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.customerrouter_1.private_ip}"]
}

resource "aws_route53_record" "customerrouter_1_dns" {
  zone_id = aws_route53_zone.environment_zone.zone_id
  name    = "customerrouter-1-public.${var.environment}.trafficcop.codametrix.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.customerrouter_1_eip.public_ip}"]
}
