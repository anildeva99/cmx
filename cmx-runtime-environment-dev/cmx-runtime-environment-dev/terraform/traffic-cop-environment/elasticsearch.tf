resource "aws_elasticsearch_domain" "elasticsearch_domain" {
  domain_name               = var.elasticsearch_domain
  elasticsearch_version     = var.elasticsearch_version

  access_policies = <<CONFIG
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": ["*"]
        },
        "Action": ["es:ESHttp*"],
        "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.elasticsearch_domain}/*"
      }
    ]
  }
CONFIG

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  cluster_config {
    instance_type = var.elasticsearch_instance_type
    instance_count = var.elasticsearch_instance_count
    dedicated_master_enabled  = var.elasticsearch_dedicated_master_enabled
    dedicated_master_count    = var.elasticsearch_dedicated_master_count
    dedicated_master_type     = "m4.large.elasticsearch"
    zone_awareness_enabled    = var.elasticsearch_zone_awareness_enabled
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = var.elasticsearch_ebs_volume_size
  }

  encrypt_at_rest {
    enabled = true
    kms_key_id = aws_kms_key.elasticsearch_kms_key.key_id
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch_domain_cwlog_group.arn
    log_type = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch_domain_cwlog_group.arn
    log_type = "ES_APPLICATION_LOGS"
  }

  node_to_node_encryption {
    enabled = true
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  # ElasticSearch will live in the application VPC... for now.
  vpc_options {
    subnet_ids = (var.elasticsearch_zone_awareness_enabled == false) ? [ aws_subnet.private_subnet_1.id ] : [ aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]
    security_group_ids = ["${aws_security_group.elasticsearch_sg.id}"]
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "elasticsearch_domain"
      Name = "CodaMetrix Traffic Cop Elasticsearch Service - elasticsearch_domain"
      Domain = "CMXTrafficCop-${var.environment}-elasticsearch_domain"
    }
  )

}
