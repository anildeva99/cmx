resource "aws_security_group" "mirth_database_sg" {
  name                   = var.mirth_database_security_group_name
  description            = "Mirth database security group"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name              = "CodaMetrix Application SG - mirth_database_sg"
      SecurityGroupName = "${var.mirth_database_security_group_name}"
    }
  )

  # Egress to anywhere
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Port 5432 ingress from Mirth instance
resource "aws_security_group_rule" "mirth_database_ingress_from_mirth_instance" {
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mirth_database_sg.id
  source_security_group_id = var.mirth_instance_sg_id
  description              = "Allow worker nodes to communicate with the Mirth database"
}

# Port 5432 ingress from bastion host
resource "aws_security_group_rule" "mirth_database_ingress_from_bastion_host" {
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mirth_database_sg.id
  source_security_group_id = var.bastion_sg_id
  description              = "Allow bastion host to communicate with the Mirth database"
}
