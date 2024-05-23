resource "aws_key_pair" "bastion_host_key_pair" {
  key_name   = var.bastion_host_key_name
  public_key = var.bastion_host_public_key
}

####################
# Dundas KeyPair
####################
resource "aws_key_pair" "dundas_key_pair" {
  key_name = var.dundas_key_name
  public_key = var.dundas_keypair_public_key
}
