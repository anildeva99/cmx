resource "aws_instance" "ingress_mirth" {
  ami                         = lookup(var.ingress_mirth_amis, var.aws_region)
  instance_type               = var.ingress_mirth_instance_type
  key_name                    = aws_key_pair.ingress_mirth_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.ingress_mirth_sg.id]
  subnet_id                   = aws_subnet.ingress_private_subnet_3.id
  associate_public_ip_address = false
  user_data                   = data.template_cloudinit_config.mirth_instance_cloudinit.rendered
  disable_api_termination     = true
  iam_instance_profile        = module.ingress_mirth.mirth_instance_profile

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 40
    delete_on_termination = true
    encrypted             = true
  }

  volume_tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_mirth"
      Name = "CodaMetrix Application EC2 - ingress_mirth"
    }
  )

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_mirth"
      Name = "CodaMetrix Application EC2 - ingress_mirth"
    }
  )
}
