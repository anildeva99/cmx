resource "aws_elasticsearch_domain" "application_elasticsearch_domain" {
  domain_name               = var.application_elasticsearch_domain
  elasticsearch_version     = var.application_elasticsearch_version

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
        "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.application_elasticsearch_domain}/*"
      }
    ]
  }
CONFIG

  # !!! Disabling elasticsearch authentication for now...
  #   access_policies = <<CONFIG
  #   {
  #     "Version": "2012-10-17",
  #     "Statement": [
  #       {
  #         "Effect": "Allow",
  #         "Principal": {
  #           "AWS": ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CMXApp-${var.environment}-cognito-es-app-user-poolauth-role"]
  #         },
  #         "Action": ["es:ESHttp*"],
  #         "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.application_elasticsearch_domain}/*"
  #       },
  #       {
  #         "Effect": "Allow",
  #         "Principal": {
  #           "AWS": "${aws_iam_role.fluentd_role.arn}"
  #         },
  #         "Action": "es:ESHttp*",
  #         "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.application_elasticsearch_domain}/*"
  #       }
  #     ]
  #   }
  # CONFIG

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  cluster_config {
    instance_type = var.application_elasticsearch_instance_type
    instance_count = var.application_elasticsearch_instance_count
    dedicated_master_enabled  = var.application_elasticsearch_dedicated_master_enabled
    dedicated_master_count    = 3
    dedicated_master_type     = "m4.large.elasticsearch"
    zone_awareness_enabled    = var.application_elasticsearch_zone_awareness_enabled
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = var.application_elasticsearch_ebs_volume_size
  }

  encrypt_at_rest {
    enabled = true
    kms_key_id = aws_kms_key.application_elasticsearch_kms_key.key_id
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.application_elasticsearch_domain_cwlog_group.arn
    log_type = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.application_elasticsearch_domain_cwlog_group.arn
    log_type = "ES_APPLICATION_LOGS"
  }

  node_to_node_encryption {
    enabled = true
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  # !!! Disabling elasticsearch authentication for now...
  # cognito_options {
  #   enabled          = true
  #   user_pool_id     = aws_cognito_user_pool.application_kibana_pool.id
  #   identity_pool_id = aws_cognito_identity_pool.application_kibana_identity.id
  #   role_arn         = aws_iam_role.es_kibana_cognito_role.arn
  # }

  # ElasticSearch will live in the application VPC... for now.
  vpc_options {
    subnet_ids = (var.application_elasticsearch_zone_awareness_enabled == false) ? [ aws_subnet.private_subnet_1.id ] : [ aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]
    security_group_ids = ["${aws_security_group.application_elasticsearch_sg.id}"]
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_elasticsearch_domain"
      Name = "CodaMetrix Application Elasticsearch Service - application_elasticsearch_domain"
      Domain = "CodaMetrixApplication-${var.environment}-application_elasticsearch_domain"
    }
  )

  depends_on = [
    aws_iam_role.es_kibana_cognito_role
  ]

}
