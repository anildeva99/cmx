#################
# VPC and Subnets
#################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Traffic Cop VPC - vpc"
      Type                                        = "vpc"
    }
  )
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.1.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}a"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Traffic Cop VPC - public_subnet_1"
      Type                                        = "public_subnet_1"
      Exposure                                    = "public"
    }
  )
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.101.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Traffic Cop VPC - private_subnet_1"
      Type                                        = "private_subnet_1"
      Exposure                                    = "private"
    }
  )
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.2.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}b"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Traffic Cop VPC - public_subnet_2"
      Type                                        = "public_subnet_2"
      Exposure                                    = "public"
    }
  )
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.102.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}b"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Traffic Cop VPC - private_subnet_2"
      Type                                        = "private_subnet_2"
      Exposure                                    = "private"
    }
  )
}

# Private subnet 3 is for mirth and it's interfaces
resource "aws_subnet" "private_subnet_3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.103.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a"

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                                = "CodaMetrix Traffic Cop VPC - private_subnet_3"
      Type                                                = "private_subnet_3"
      Exposure                                            = "private"
      IPAssignment                                        = "static"
    }
  )
}

resource "aws_subnet" "dmz_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.vpc_subnet_cidr_block_prefix}.254.${var.vpc_subnet_cidr_block_suffix}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}b"

  tags = merge(
    var.shared_resource_tags,
    {
      Name     = "CodaMetrix Traffic Cop VPC - dmz_subnet"
      Type     = "dmz_subnet"
      Exposure = "dmz"
    }
  )
}

################################################
# Inernet Gateway and Routing for Public Subnets
################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Traffic Cop VPC - igw"
      Type = "igw"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Traffic Cop VPC - public_route_table"
      Type = "public_route_table"
    }
  )
}

resource "aws_route" "public_route_internet" {
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
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
      Name = "CodaMetrix Traffic Cop VPC - eip"
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
      Name = "CodaMetrix Traffic Cop VPC - nat_gateway"
      Type = "nat_gateway"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Traffic Cop VPC - private_route_table"
      Type = "private_route_table"
    }
  )
}

resource "aws_route" "private_route_internet" {
  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_route_table.id
}

################################
# Peering connections and routes
################################
data "aws_vpc_peering_connection" "peering_connections" {
  for_each   = var.peer_vpc_routes
  tags = {
    Name  = each.value.pcx_name
  }
}

resource "aws_route" "private_route_peering_routes" {
  for_each                  = var.peer_vpc_routes
  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = each.value.destination_cidr
  vpc_peering_connection_id = data.aws_vpc_peering_connection.peering_connections[each.key].id
}

resource "aws_route" "public_route_peering_routes" {
  for_each                  = var.peer_vpc_routes
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = each.value.destination_cidr
  vpc_peering_connection_id = data.aws_vpc_peering_connection.peering_connections[each.key].id
}
