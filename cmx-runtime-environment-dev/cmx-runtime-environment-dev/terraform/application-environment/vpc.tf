#################
# VPC and Subnets
#################
resource "aws_vpc" "application_vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Application VPC - application_vpc"
      Type                                        = "application_vpc"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.1.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}a"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Application VPC - public_subnet_1"
      Type                                        = "public_subnet_1"
      Exposure                                    = "public"
      VPC                                         = "application"
      "kubernetes.io/role/elb"                    = 1
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.101.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Application VPC - private_subnet_1"
      Type                                        = "private_subnet_1"
      Exposure                                    = "private"
      VPC                                         = "application"
      "kubernetes.io/role/internal-elb"           = 1
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.2.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}b"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Application VPC - public_subnet_2"
      Type                                        = "public_subnet_2"
      Exposure                                    = "public"
      VPC                                         = "application"
      "kubernetes.io/role/elb"                    = 1
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.102.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}b"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Application VPC - private_subnet_2"
      Type                                        = "private_subnet_2"
      Exposure                                    = "private"
      VPC                                         = "application"
      "kubernetes.io/role/internal-elb"           = 1
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

resource "aws_subnet" "dmz_subnet" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.254.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}b"

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Application VPC - dmz_subnet"
      Type     = "dmz_subnet"
      Exposure = "dmz"
      VPC      = "application"
    }
  )
}

################################################
# Inernet Gateway and Routing for Public Subnets
################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.application_vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - igw"
      Type = "igw"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.application_vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - public_route_table"
      Type = "public_route_table"
    }
  )
}

resource "aws_route" "public_route_internet" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_dmz" {
  subnet_id      = aws_subnet.dmz_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

#############################################
# NAT Gateway and Routing for Private Subnets
#############################################
resource "aws_eip" "eip" {
  vpc = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - eip"
      Type = "eip"
    }
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - nat_gateway"
      Type = "nat_gateway"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.application_vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - private_route_table"
      Type = "private_route_table"
    }
  )
}

resource "aws_route" "private_route_internet" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

#########################
# Ingress VPC and Subnets
#########################
resource "aws_vpc" "ingress_vpc" {
  cidr_block           = var.ingress_vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - ingress_vpc"
      Type = "ingress_vpc"
    }
  )
}

resource "aws_subnet" "ingress_public_subnet_1" {
  vpc_id                  = aws_vpc.ingress_vpc.id
  cidr_block              = "${var.ingress_vpc_subnet_cidr_block_prefix}.1.${var.ingress_vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}a"

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Application VPC - ingress_public_subnet_1"
      Type     = "ingress_public_subnet_1"
      Exposure = "public"
      VPC      = "ingress"
    }
  )
}

resource "aws_subnet" "ingress_public_subnet_2" {
  vpc_id                  = aws_vpc.ingress_vpc.id
  cidr_block              = "${var.ingress_vpc_subnet_cidr_block_prefix}.2.${var.ingress_vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}b"

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Application VPC - ingress_public_subnet_2"
      Type     = "ingress_public_subnet_2"
      Exposure = "public"
      VPC      = "ingress"
    }
  )
}

resource "aws_subnet" "ingress_private_subnet_1" {
  vpc_id                  = aws_vpc.ingress_vpc.id
  cidr_block              = "${var.ingress_vpc_subnet_cidr_block_prefix}.101.${var.ingress_vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a"

  tags = merge(
    var.shared_resource_tags,
    {
      Name         = "CodaMetrix Application VPC - ingress_private_subnet_1"
      Type         = "ingress_private_subnet_1"
      Exposure     = "private"
      VPC          = "ingress"
      IPAssignment = "dynamic"
    }
  )
}

resource "aws_subnet" "ingress_private_subnet_2" {
  vpc_id                  = aws_vpc.ingress_vpc.id
  cidr_block              = "${var.ingress_vpc_subnet_cidr_block_prefix}.102.${var.ingress_vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}b"

  tags = merge(
    var.shared_resource_tags,
    {
      Name         = "CodaMetrix Application VPC - ingress_private_subnet_2"
      Type         = "ingress_private_subnet_2"
      Exposure     = "private"
      VPC          = "ingress"
      IPAssignment = "dynamic"
    }
  )
}

# Private subnet 3 is for ingress Mirth and it's interfaces
resource "aws_subnet" "ingress_private_subnet_3" {
  vpc_id                  = aws_vpc.ingress_vpc.id
  cidr_block              = "${var.ingress_vpc_subnet_cidr_block_prefix}.103.${var.ingress_vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a"

  tags = merge(
    var.shared_resource_tags,
    {
      Name         = "CodaMetrix Application VPC - ingress_private_subnet_3"
      Type         = "ingress_private_subnet_3"
      Exposure     = "private"
      VPC          = "ingress"
      IPAssignment = "static"
    }
  )
}

resource "aws_subnet" "ingress_dmz_subnet" {
  vpc_id                  = aws_vpc.ingress_vpc.id
  cidr_block              = "${var.ingress_vpc_subnet_cidr_block_prefix}.254.${var.ingress_vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}b"

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Application VPC - ingress_dmz_subnet"
      Type     = "ingress_dmz_subnet"
      Exposure = "dmz"
      VPC      = "ingress"
    }
  )
}


###################################################################
# Inernet Gateway and Routing for Public Subnets in the Ingress VPC
###################################################################
resource "aws_internet_gateway" "ingress_igw" {
  vpc_id = aws_vpc.ingress_vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - ingress_igw"
      Type = "ingress_igw"
    }
  )
}

resource "aws_route_table" "ingress_public_route_table" {
  vpc_id = aws_vpc.ingress_vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - ingress_public_route_table"
      Type = "ingress_public_route_table"
    }
  )
}

resource "aws_route" "ingress_public_route_internet" {
  route_table_id         = aws_route_table.ingress_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ingress_igw.id
}

resource "aws_route_table_association" "ingress_public_route_table_association_1" {
  subnet_id      = aws_subnet.ingress_public_subnet_1.id
  route_table_id = aws_route_table.ingress_public_route_table.id
}

resource "aws_route_table_association" "ingress_public_route_table_association_2" {
  subnet_id      = aws_subnet.ingress_public_subnet_2.id
  route_table_id = aws_route_table.ingress_public_route_table.id
}

resource "aws_route_table_association" "ingress_public_route_table_association_dmz" {
  subnet_id      = aws_subnet.ingress_dmz_subnet.id
  route_table_id = aws_route_table.ingress_public_route_table.id
}

#####################################################
# NAT Gateway and Routing for Private Ingress Subnets
#####################################################
resource "aws_eip" "ingress_eip" {
  vpc = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - ingress_eip"
      Type = "ingress_eip"
    }
  )
}

resource "aws_nat_gateway" "ingress_nat_gateway" {
  allocation_id = aws_eip.ingress_eip.id
  subnet_id     = aws_subnet.ingress_public_subnet_1.id
  depends_on    = [aws_internet_gateway.ingress_igw]

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - ingress_nat_gateway"
      Type = "ingress_nat_gateway"
    }
  )
}

resource "aws_route_table" "ingress_private_route_table" {
  vpc_id = aws_vpc.ingress_vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application VPC - ingress_private_route_table"
      Type = "ingress_private_route_table"
    }
  )
}

resource "aws_route" "ingress_private_route_internet" {
  route_table_id         = aws_route_table.ingress_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ingress_nat_gateway.id
}

resource "aws_route_table_association" "ingress_private_route_table_association_1" {
  subnet_id      = aws_subnet.ingress_private_subnet_1.id
  route_table_id = aws_route_table.ingress_private_route_table.id
}

resource "aws_route_table_association" "ingress_private_route_table_association_2" {
  subnet_id      = aws_subnet.ingress_private_subnet_2.id
  route_table_id = aws_route_table.ingress_private_route_table.id
}

resource "aws_route_table_association" "ingress_private_route_table_association_3" {
  subnet_id      = aws_subnet.ingress_private_subnet_3.id
  route_table_id = aws_route_table.ingress_private_route_table.id
}

###########################################################
# EMR Cluster subnet
###########################################################
data "aws_availability_zones" "application_azs" {
  state = "available"
}

# I put EMR/MSK clusters in seperated subnets for granular modulization,
# Suppose for some reason we need delete subnet of Kubernetes,
# we can still have EMR cluster intacted.
# Distributing these subnets in diffirent availablity zone also increase reliabity
# because if one zone is not available, we have brokers still work in different zones
# One VPC could have up to 200 subnets, creating subnet itself won't incurr cost.
resource "aws_subnet" "emr_private_subnet" {
  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = var.emr_subnet_cidr_block
  availability_zone = data.aws_availability_zones.application_azs.names[0]

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Application VPC - emr_private_subnet"
      Type     = "emr_private_subnet"
      Exposure = "private"
      VPC      = "Application"
    }
  )
}

resource "aws_route_table_association" "private_route_table_association_emr" {
  subnet_id      = aws_subnet.emr_private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

###########################################################
# MSK subnets
###########################################################
resource "aws_subnet" "msk_private_subnet_az" {
  count             = length(var.msk_private_subnet_cidr_block)
  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = var.msk_private_subnet_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.application_azs.names[count.index]

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Application VPC - msk_private_subnet_az"
      Type     = "msk_private_subnet_az"
      Exposure = "private"
      VPC      = "Application"
    }
  )
}

################################
# Peering connections and routes
################################
data "aws_vpc_peering_connection" "application_peering_connections" {
  for_each = var.application_peer_vpc_routes
  tags = {
    Name = each.value.pcx_name
  }
}

resource "aws_route" "application_private_route_peering_routes" {
  for_each                  = var.application_peer_vpc_routes
  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = each.value.destination_cidr
  vpc_peering_connection_id = data.aws_vpc_peering_connection.application_peering_connections[each.key].id
}

resource "aws_route" "application_public_route_peering_routes" {
  for_each                  = var.application_peer_vpc_routes
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = each.value.destination_cidr
  vpc_peering_connection_id = data.aws_vpc_peering_connection.application_peering_connections[each.key].id
}

data "aws_vpc_peering_connection" "ingress_peering_connections" {
  for_each = var.ingress_peer_vpc_routes
  tags = {
    Name = each.value.pcx_name
  }
}

resource "aws_route" "ingress_private_route_peering_routes" {
  for_each                  = var.ingress_peer_vpc_routes
  route_table_id            = aws_route_table.ingress_private_route_table.id
  destination_cidr_block    = each.value.destination_cidr
  vpc_peering_connection_id = data.aws_vpc_peering_connection.ingress_peering_connections[each.key].id
}

resource "aws_route" "ingress_public_route_peering_routes" {
  for_each                  = var.ingress_peer_vpc_routes
  route_table_id            = aws_route_table.ingress_public_route_table.id
  destination_cidr_block    = each.value.destination_cidr
  vpc_peering_connection_id = data.aws_vpc_peering_connection.ingress_peering_connections[each.key].id
}

##############################################
# ACL to limit traffic from Application mirth
##############################################
resource "aws_network_acl" "ingress_traffic_from_application_acl" {
  vpc_id     = aws_vpc.ingress_vpc.id
  subnet_ids = [aws_subnet.ingress_private_subnet_1.id, aws_subnet.ingress_private_subnet_2.id, aws_subnet.ingress_private_subnet_3.id]

  ingress {
    protocol   = -1
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 130
    action     = "deny"
    cidr_block = aws_vpc.application_vpc.cidr_block
    from_port  = 0
    to_port    = 0
  }

  dynamic "ingress" {
    for_each = toset(var.app_mirth_to_ingress_mirth_open_ports)
    content {
      protocol   = "tcp"
      rule_no    = ingress.value
      action     = "allow"
      cidr_block = aws_vpc.application_vpc.cidr_block
      from_port  = ingress.value
      to_port    = ingress.value
    }
  }



  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Application VPC - ingress_private_network_acl"
      Type     = "ingress_private_network_acl"
      Exposure = "private"
      VPC      = "Ingress"
    }
  )
}

#########
# Outputs
#########
output "vpc_arn" {
  value = aws_vpc.application_vpc.arn
}

output "vpc_public_subnet_arns" {
  value = [aws_subnet.public_subnet_1.arn, aws_subnet.public_subnet_2.arn]
}

output "vpc_private_subnet_arns" {
  value = [aws_subnet.private_subnet_1.arn, aws_subnet.private_subnet_2.arn]
}

output "vpc_dmz_subnet_arn" {
  value = aws_subnet.dmz_subnet.arn
}

output "vpc_igw" {
  value = aws_internet_gateway.igw.id
}

output "vpc_public_route_table" {
  value = aws_route_table.public_route_table.id
}

output "vpc_eip_public_ip" {
  value = aws_eip.eip.public_ip
}

output "vpc_eip_public_dns" {
  value = aws_eip.eip.public_dns
}

output "vpc_private_route_table" {
  value = aws_route_table.private_route_table.id
}

output "ingress_vpc_arn" {
  value = aws_vpc.ingress_vpc.arn
}

output "ingress_vpc_public_subnet_arns" {
  value = [aws_subnet.ingress_public_subnet_1.arn, aws_subnet.ingress_public_subnet_2.arn]
}

output "ingress_vpc_private_subnet_arns" {
  value = [aws_subnet.ingress_private_subnet_1.arn, aws_subnet.ingress_private_subnet_2.arn]
}

output "ingress_vpc_dmz_subnet_arn" {
  value = aws_subnet.ingress_dmz_subnet.arn
}

output "ingress_vpc_igw" {
  value = aws_internet_gateway.ingress_igw.id
}

output "ingress_vpc_public_route_table" {
  value = aws_route_table.ingress_public_route_table.id
}

output "ingress_vpc_eip_public_ip" {
  value = aws_eip.ingress_eip.public_ip
}

output "ingress_vpc_eip_public_dns" {
  value = aws_eip.ingress_eip.public_dns
}

output "ingress_vpc_private_route_table" {
  value = aws_route_table.ingress_private_route_table.id
}
