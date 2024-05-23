resource "aws_instance" "customerrouter_1" {
  ami                         = lookup(var.customerrouter_amis, var.aws_region)
  instance_type               = var.customerrouter_instance_type
  key_name                    = aws_key_pair.customerrouter_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.customerrouter_1_sg.id]
  subnet_id                   = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  source_dest_check           = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customerrouter_1"
      Name = "CodaMetrix Application EC2 - customerrouter_1"
    }
  )
}

resource "aws_network_interface" "customerrouter_1_private_interface" {
  subnet_id         = aws_subnet.private_subnet_1.id
  security_groups   = ["${aws_security_group.customerrouter_1_sg.id}"]
  source_dest_check = false

  attachment {
    instance     = aws_instance.customerrouter_1.id
    device_index = 1
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customerrouter_1_private_interface"
      Name = "CodaMetrix Application ENI - customerrouter_1_private_interface"
    }
  )
}

resource "aws_eip" "customerrouter_1_eip" {
  network_interface = aws_instance.customerrouter_1.primary_network_interface_id
  vpc               = true

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customerrouter_1_eip"
      Name = "CodaMetrix Application EIP - customerrouter_1_eip"
    }
  )
}
