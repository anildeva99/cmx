resource "aws_instance" "customer_networking_csr_1" {
  count                       = var.enable_customer_networking ? 1 : 0
  ami                         = lookup(var.customer_networking_amis, var.aws_region)
  instance_type               = var.customer_networking_instance_type
  key_name                    = element(aws_key_pair.customer_networking_key_pair.*.key_name, 0)
  vpc_security_group_ids      = [aws_security_group.ingress_customer_networking_sg.id]
  subnet_id                   = aws_subnet.ingress_public_subnet_1.id
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
      Type = "customer_networking_csr_1"
      Name = "CodaMetrix Application EC2 - customer_networking_csr_1"
    }
  )
}

resource "aws_network_interface" "customer_networking_csr_1_private_interface" {
  count             = var.enable_customer_networking ? 1 : 0
  subnet_id         = aws_subnet.ingress_private_subnet_1.id
  security_groups   = ["${aws_security_group.ingress_customer_networking_sg.id}"]
  source_dest_check = false

  attachment {
    instance     = aws_instance.customer_networking_csr_1[0].id
    device_index = 1
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customer_networking_csr_1_private_interface"
      Name = "CodaMetrix Application ENI - customer_networking_csr_1_private_interface"
    }
  )
}

resource "aws_eip" "customer_networking_csr_1_eip" {
  count = var.enable_customer_networking ? 1 : 0
  #instance           = element(aws_instance.customer_networking_csr_1.*.id, 0)
  network_interface = aws_instance.customer_networking_csr_1[0].primary_network_interface_id
  vpc               = true

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "customer_networking_csr_1_eip"
      Name = "CodaMetrix Application EIP - customer_networking_csr_1_eip"
    }
  )
}

output "customer_networking_csr_1_id" {
  value = aws_instance.customer_networking_csr_1.*.id
}

output "customer_networking_csr_1_arn" {
  value = aws_instance.customer_networking_csr_1.*.arn
}

output "customer_networking_csr_1_public_address" {
  value = aws_eip.customer_networking_csr_1_eip.*.public_ip
}
