resource "aws_instance" "bastion_host" {
  ami                         = lookup(var.bastion_amis, var.aws_region)
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.bastion_host_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  subnet_id                   = aws_subnet.dmz_subnet.id
  associate_public_ip_address = true
  user_data                   = data.template_cloudinit_config.bastion_host_cloudinit.rendered

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "bastion_host"
      Name = "CodaMetrix Traffic Cop EC2 - bastion_host"
    }
  )
}
