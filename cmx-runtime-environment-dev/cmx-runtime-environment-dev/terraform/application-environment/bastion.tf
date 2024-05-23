resource "aws_instance" "bastion_host" {
  ami                         = lookup(var.bastion_amis, var.aws_region)
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.bastion_host_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.application_bastion_sg.id]
  subnet_id                   = aws_subnet.dmz_subnet.id
  associate_public_ip_address = true
  user_data                   = data.template_cloudinit_config.bastion_host_cloudinit.rendered

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  volume_tags = merge(
    var.shared_resource_tags,
    {
      Type = "bastion_host"
      Name = "CodaMetrix Application EC2 - bastion_host"
    }
  )

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "bastion_host"
      Name = "CodaMetrix Application EC2 - bastion_host"
    }
  )
}

resource "aws_instance" "ingress_bastion_host" {
  ami                         = lookup(var.bastion_amis, var.aws_region)
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.bastion_host_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.ingress_bastion_sg.id]
  subnet_id                   = aws_subnet.ingress_dmz_subnet.id
  associate_public_ip_address = true
  user_data                   = data.template_cloudinit_config.bastion_host_cloudinit.rendered

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  volume_tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_bastion_host"
      Name = "CodaMetrix Application EC2 - ingress_bastion_host"
    }
  )

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_bastion_host"
      Name = "CodaMetrix Application EC2 - ingress_bastion_host"
    }
  )
}

output "bastion_host_id" {
  value = aws_instance.bastion_host.id
}

output "bastion_host_arn" {
  value = aws_instance.bastion_host.arn
}

output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "ingress_bastion_host_id" {
  value = aws_instance.ingress_bastion_host.id
}

output "ingress_bastion_host_arn" {
  value = aws_instance.ingress_bastion_host.arn
}

output "ingress_bastion_host_public_ip" {
  value = aws_instance.ingress_bastion_host.public_ip
}
