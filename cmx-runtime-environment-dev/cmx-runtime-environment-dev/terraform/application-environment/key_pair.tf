resource "aws_key_pair" "worker_node_key_pair" {
  key_name   = var.node_key_name
  public_key = var.node_public_key
}

resource "aws_key_pair" "emr_host_key_pair" {
  key_name = var.data_lake_emr_host_key_name
  public_key = var.data_lake_emr_host_public_key
}

resource "aws_key_pair" "customer_networking_key_pair" {
  count      = var.enable_customer_networking ? 1 : 0
  key_name   = var.customer_networking_key_name
  public_key = var.customer_networking_public_key
}

resource "aws_key_pair" "bastion_host_key_pair" {
  key_name   = var.bastion_host_key_name
  public_key = var.bastion_host_public_key
}

resource "aws_key_pair" "ingress_mirth_key_pair" {
  key_name   = var.ingress_mirth_key_name
  public_key = var.ingress_mirth_public_key
}
