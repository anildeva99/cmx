resource "aws_key_pair" "customerrouter_key_pair" {
  key_name   = var.customerrouter_key_name
  public_key = var.customerrouter_public_key
}

resource "aws_key_pair" "bastion_host_key_pair" {
  key_name   = var.bastion_host_key_name
  public_key = var.bastion_host_public_key
}

resource "aws_key_pair" "mirth_key_pair" {
  key_name   = var.mirth_key_name
  public_key = var.mirth_public_key
}
