# Used for external, customer-facing DNS names
resource "aws_route53_zone" "cmx_automate_zone" {
  name          = var.cmx_automate_dns_name
  force_destroy = false

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "cmx_automate_zone"
      Name = "CodaMetrix Application Route 53 - cmx_automate_zone"
    }
  )
}

# Used for environment-level DNS names
resource "aws_route53_zone" "environment_zone" {
  name          = "${var.environment}.codametrix.com"
  force_destroy = false

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_zone"
      Name = "CodaMetrix Application Route 53 - environment_zone"
    }
  )
}

# Used for internal (backend) DNS names, nothing customer facing
resource "aws_route53_zone" "application_zone" {
  name          = "${var.environment}.application.codametrix.com"
  force_destroy = false

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_zone"
      Name = "CodaMetrix Application Route 53 - application_zone"
    }
  )
}

resource "aws_route53_record" "bastion_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "bastion.${var.environment}.application.codametrix.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bastion_host.private_ip}"]
}

resource "aws_route53_record" "codametrix_ses" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "_amazonses.${var.environment}.application.codametrix.com"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.codametrix_domain_identity.verification_token}"]
}

resource "aws_route53_record" "ingress_bastion_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "ingress-bastion.${var.environment}.application.codametrix.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.ingress_bastion_host.private_ip}"]
}

resource "aws_route53_record" "database_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "database.${var.environment}.application.codametrix.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.application_database.address}"]
}

resource "aws_route53_record" "ingress_mirth_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = var.ingress_mirthconnect_dns_address
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.ingress_mirth.private_ip}"]
}

resource "aws_route53_record" "mirth_database_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "mirth-database.${var.environment}.application.codametrix.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.mirth.mirth_database_address}"]
}

resource "aws_route53_record" "ingress_mirth_database_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "ingress-mirth-database.${var.environment}.application.codametrix.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.ingress_mirth.mirth_database_address}"]
}

resource "aws_route53_record" "warehouse_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "warehouse.${var.environment}.application.codametrix.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_redshift_cluster.application_data_warehouse.dns_name}"]
}

resource "aws_route53_record" "elasticsearch_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "elasticsearch.${var.environment}.application.codametrix.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elasticsearch_domain.application_elasticsearch_domain.endpoint}"]
}

resource "aws_route53_record" "customer_networking_csr_1_private_dns" {
  count   = var.enable_customer_networking ? 1 : 0
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "csr-1-private.${var.environment}.application.codametrix.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.customer_networking_csr_1[0].private_ip}"]
}

resource "aws_route53_record" "customer_networking_csr_1_dns" {
  count   = var.enable_customer_networking ? 1 : 0
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "csr-1.${var.environment}.application.codametrix.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.customer_networking_csr_1_eip[0].public_ip}"]
}

resource "aws_route53_record" "kafka_broker_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "kafka.${var.environment}.application.codametrix.com"
  type    = "CNAME"
  ttl     = "300"
  records = [element(split(":", element(split(",", "${aws_msk_cluster.application_data_warehouse_msk_cluster.bootstrap_brokers_tls}"), 0)),0)]
}

resource "aws_route53_record" "kafka_zookeeper_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = "zookeeper.${var.environment}.application.codametrix.com"
  type    = "CNAME"
  ttl     = "300"
  records = [element(split(":", element(split(",", "${aws_msk_cluster.application_data_warehouse_msk_cluster.zookeeper_connect_string}"), 0)),0)]
}

/*
resource "aws_route53_record" "static_dns" {
  zone_id = aws_route53_zone.application_zone.zone_id
  name    = var.application_static_dns_address
  type    = "CNAME"
  ttl     = "300"
  records = [ "${aws_cloudfront_distribution.application_static_distribution.domain_name}" ]
}*/

output "application_zone_id" {
  value = aws_route53_zone.application_zone.zone_id
}

output "application_zone_name_servers" {
  value = aws_route53_zone.application_zone.name_servers
}

output "bastion_dns_address" {
  value = aws_route53_record.bastion_dns.name
}

output "database_dns_address" {
  value = aws_route53_record.database_dns.name
}

output "warehouse_dns_address" {
  value = aws_route53_record.warehouse_dns.name
}

output "elasticsearch_dns_address" {
  value = aws_route53_record.elasticsearch_dns.name
}

/*
output "static_dns_address" {
  value = aws_route53_record.static_dns.name
}
*/
