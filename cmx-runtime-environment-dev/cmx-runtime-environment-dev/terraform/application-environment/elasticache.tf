resource "aws_elasticache_replication_group" "application_redis_replication_group" {
  at_rest_encryption_enabled = true

  # !!! Kind of sucks that this value apparently can't be changed,
  # and it's stored in the clear in TF state, but it's just ElastiCache...?
  auth_token                    = var.elasticache_password
  automatic_failover_enabled    = true
  auto_minor_version_upgrade    = true
  availability_zones            = ["${var.aws_region}a", "${var.aws_region}b"]
  engine                        = "redis"
  engine_version                = "5.0.4"
  multi_az_enabled              = true
  node_type                     = var.elasticache_node_type
  number_cache_clusters         = var.elasticache_number_cache_clusters
  port                          = 6379
  replication_group_id          = var.elasticache_rg_id
  replication_group_description = "Redis replication group for the '${var.environment}' application environment"
  security_group_ids            = [aws_security_group.application_redis_sg.id]
  subnet_group_name             = aws_elasticache_subnet_group.application_redis_subnet_group.name
  transit_encryption_enabled    = true

  lifecycle {
    ignore_changes = [number_cache_clusters]
  }
}

resource "aws_elasticache_cluster" "application_redis_cluster" {
  cluster_id           = var.elasticache_cluster_id
  replication_group_id = aws_elasticache_replication_group.application_redis_replication_group.id
}

resource "aws_elasticache_subnet_group" "application_redis_subnet_group" {
  name       = "codametrixapplication-${var.environment}-redis-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "application_redis_replication_group_id" {
  value = aws_elasticache_replication_group.application_redis_replication_group.id
}

output "application_redis_replication_group_configuration_endpoint_address" {
  value = aws_elasticache_replication_group.application_redis_replication_group.configuration_endpoint_address
}

output "application_redis_replication_group_primary_endpoint_address" {
  value = aws_elasticache_replication_group.application_redis_replication_group.primary_endpoint_address
}

output "application_redis_cluster_cache_nodes" {
  value = aws_elasticache_cluster.application_redis_cluster.cache_nodes
}
