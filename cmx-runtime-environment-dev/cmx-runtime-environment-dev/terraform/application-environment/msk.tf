resource "aws_msk_configuration" "application_data_warehouse_msk_cluster_config" {
  kafka_versions = [var.kafka_version]
  # underscore is not allowed in the name, so use hiphens
  name = "CMXApp-${var.environment}-${random_id.id.hex}-app-data-warehouse-msk-cluster-config"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
PROPERTIES
}

resource "aws_msk_cluster" "application_data_warehouse_msk_cluster" {
  # underscore is not allowed in the name, so use hiphens
  cluster_name           = "CMXApp-${var.environment}-application-data-warehouse-msk-cluster"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_kafka_broker_nodes
  enhanced_monitoring    = var.kafka_enhanced_monitoring

  broker_node_group_info {
    instance_type   = var.msk_instance_type
    ebs_volume_size = var.msk_ebs_volume_size
    client_subnets  = aws_subnet.msk_private_subnet_az.*.id
    security_groups = [aws_security_group.application_msk_sg.id]
    az_distribution = var.kafka_avail_zone_distribution
  }

  configuration_info {
    arn      = aws_msk_configuration.application_data_warehouse_msk_cluster_config.arn
    revision = 1
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.application_data_warehouse_kms_key.arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_warehouse_msk_cluster"
      Name = "CodaMetrix Application MSK - application_data_warehouse_msk_cluster"
    }
  )
}

output "zookeeper_connect_string" {
  value = "${aws_msk_cluster.application_data_warehouse_msk_cluster.zookeeper_connect_string}"
}

output "bootstrap_brokers" {
  description = "Plaintext connection host:port pairs"
  value       = aws_msk_cluster.application_data_warehouse_msk_cluster.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.application_data_warehouse_msk_cluster.bootstrap_brokers_tls
}
