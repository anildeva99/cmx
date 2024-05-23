resource "aws_security_group" "bastion_sg" {
  name                   = "CMXTrafficCop-${var.environment}-bastion_sg"
  description            = "Bastion host security group"
  vpc_id                 = aws_vpc.vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - bastion_sg"
      Type = "bastion_sg"
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

resource "aws_security_group_rule" "bastion_ingress_from_cidr" {
  count                    = length(var.bastion_ingress_from_cidr_sgs)
  type                     = "ingress"
  from_port                = element(var.bastion_ingress_from_cidr_sgs, count.index).from_port
  to_port                  = element(var.bastion_ingress_from_cidr_sgs, count.index).to_port
  protocol                 = element(var.bastion_ingress_from_cidr_sgs, count.index).protocol
  security_group_id        = aws_security_group.bastion_sg.id
  cidr_blocks              = element(var.bastion_ingress_from_cidr_sgs, count.index).cidr_blocks
  description              = element(var.bastion_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "bastion_ingress_from_sg" {
  count                    = length(var.bastion_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.bastion_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.bastion_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.bastion_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.bastion_sg.id
  source_security_group_id = element(var.bastion_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.bastion_ingress_from_sg_sgs, count.index).description
}

# Port 443 for ElasticSearch service
resource "aws_security_group" "elasticsearch_sg" {
  name        = "CMXTrafficCop-${var.environment}-elasticsearch_sg"
  description = "Elasticsearch security group"

  # ElasticSearch will live in the application VPC...
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Traffic Cop SG - elasticsearch_sg"
      Type = "elasticsearch_sg"
    }
  )

  ingress {
    description = "HTTPS access within the VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_vpc.vpc.cidr_block}",
    ]
  }

  ingress {
    description = "API acccess within the VPC"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_vpc.vpc.cidr_block}",
    ]
  }
}

resource "aws_security_group" "customerrouter_1_sg" {
  name                   = "CMXTrafficCop-${var.environment}-customerrouter_1_sg"
  description            = "Customer Router 1 security group"
  vpc_id                 = aws_vpc.vpc.id
  revoke_rules_on_delete = true

  tags = {
    Usage       = "CodaMetrix Traffic Cop"
    Name        = "CodaMetrix Traffic Cop SG - customerrouter_1_sg"
    Environment = var.environment
  }

  # Egress to the outside world
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Port 22 (SSH) ingress from bastion host
resource "aws_security_group_rule" "customerrouter_1_ingress_from_bastion_host" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.customerrouter_1_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "Allow bastion host to communicate with Customer Router 1"
}

# UDP Port 500 (ISAKMP) ingress from the outside world
resource "aws_security_group_rule" "customerrouter_1_isakmp" {
  type                     = "ingress"
  from_port                = "500"
  to_port                  = "500"
  protocol                 = "udp"
  security_group_id        = aws_security_group.customerrouter_1_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "Allow ISAKMP ingress from the outside world"
}

# UDP Port 4500 (IPSEC) ingress from the outside world
resource "aws_security_group_rule" "customerrouter_1_ipsec" {
  type                     = "ingress"
  from_port                = "4500"
  to_port                  = "4500"
  protocol                 = "udp"
  security_group_id        = aws_security_group.customerrouter_1_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "Allow IPSEC ingress from the outside world"
}

# IP protocol 50 (Encapsulating Security Payload) ingress from the outside world
resource "aws_security_group_rule" "customerrouter_1_esp" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "50"
  security_group_id        = aws_security_group.customerrouter_1_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "Allow ESP ingress from the outside world"
}

# IP protocol 51 (Authentication Header) ingress from the outside world
resource "aws_security_group_rule" "customerrouter_1_ah" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "51"
  security_group_id        = aws_security_group.customerrouter_1_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "Allow AH ingress from the outside world"
}

resource "aws_security_group_rule" "customerrouter_1_icmp" {
   type                     = "ingress"
   from_port                = "-1"
   to_port                  = "-1"
   protocol                 = "icmp"
   security_group_id        = aws_security_group.customerrouter_1_sg.id
   cidr_blocks              = ["${var.vpc_subnet_cidr_block_prefix}.0.0/16"]
   description              = "Allow all ICMP ingress from the ingress network"
}

# Ingress traffic from the Partners Mirth channels
resource "aws_security_group_rule" "customerrouter_1_partners_ports" {
   count                    = length(var.partners_ingress_open_ports)
   type                     = "ingress"
   from_port                = element(var.partners_ingress_open_ports, count.index)
   to_port                  = element(var.partners_ingress_open_ports, count.index)
   protocol                 = "tcp"
   security_group_id        = aws_security_group.customerrouter_1_sg.id
   source_security_group_id = aws_security_group.mirth_sg.id
   description              = "Allow tcp port ${element(var.partners_ingress_open_ports, count.index)} ingress from the Partners Mirth channel"
}

# Ingress traffic from the CU Medicine Mirth channels
resource "aws_security_group_rule" "customerrouter_1_cumedicine_ports" {
   count                    = length(var.cumedicine_ingress_open_ports)
   type                     = "ingress"
   from_port                = element(var.cumedicine_ingress_open_ports, count.index)
   to_port                  = element(var.cumedicine_ingress_open_ports, count.index)
   protocol                 = "tcp"
   security_group_id        = aws_security_group.customerrouter_1_sg.id
   source_security_group_id = aws_security_group.mirth_sg.id
   description              = "Allow tcp port ${element(var.cumedicine_ingress_open_ports, count.index)} ingress from the CU Medicine Mirth channel"
}

# Ingress traffic from the Yale Mirth channels
resource "aws_security_group_rule" "customerrouter_1_yale_ports" {
   count                    = length(var.yale_ingress_open_ports)
   type                     = "ingress"
   from_port                = element(var.yale_ingress_open_ports, count.index)
   to_port                  = element(var.yale_ingress_open_ports, count.index)
   protocol                 = "tcp"
   security_group_id        = aws_security_group.customerrouter_1_sg.id
   source_security_group_id = aws_security_group.mirth_sg.id
   description              = "Allow tcp port ${element(var.yale_ingress_open_ports, count.index)} ingress from the Yale Mirth channel"
}

# !!! Ingress traffic from Mirth - All Ports !!!
# !!! I hate to have to do this but for some reason, both Colorado and Partners have had issues (traffic working in one direction, but not both)
# !!! without this rule in place. We should remove this as soon as we can figure out how.
resource "aws_security_group_rule" "customerrouter_1_all_ports_from_mirth" {
   type                     = "ingress"
   from_port                = 0
   to_port                  = 65535
   protocol                 = "tcp"
   security_group_id        = aws_security_group.customerrouter_1_sg.id
   source_security_group_id = aws_security_group.mirth_sg.id
   description              = "!!! Danger - Allow ALL tcp port ingress from mirth"
}

##################
# Mirth
##################
resource "aws_security_group" "mirth_sg" {
  name                   = "CMXTrafficCop-${var.environment}-mirth_sg"
  description            = "Mirth security group"
  vpc_id                 = aws_vpc.vpc.id
  revoke_rules_on_delete = true

  tags = {
    Usage       = "CodaMetrix Traffic Cop"
    Name        = "CodaMetrix Traffic Cop SG - mirth_sg"
    Environment = var.environment
  }

  # Egress to the outside world
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Port 22 (SSH) ingress from bastion host
resource "aws_security_group_rule" "mirth_ingress_from_bastion_host" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mirth_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "Allow ingress bastion host to communicate with mirth"
}

resource "aws_security_group_rule" "mirth_connect_api_ingress_from_cidr" {
  count                    = length(var.mirth_connect_api_ingress_from_cidr_sgs)
  type                     = "ingress"
  from_port                = element(var.mirth_connect_api_ingress_from_cidr_sgs, count.index).from_port
  to_port                  = element(var.mirth_connect_api_ingress_from_cidr_sgs, count.index).to_port
  protocol                 = element(var.mirth_connect_api_ingress_from_cidr_sgs, count.index).protocol
  security_group_id        = aws_security_group.mirth_sg.id
  cidr_blocks              = element(var.mirth_connect_api_ingress_from_cidr_sgs, count.index).cidr_blocks
  description              = element(var.mirth_connect_api_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "mirth_connect_api_ingress_from_sg" {
  count                    = length(var.mirth_connect_api_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.mirth_connect_api_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.mirth_connect_api_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.mirth_connect_api_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.mirth_sg.id
  source_security_group_id = element(var.mirth_connect_api_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.mirth_connect_api_ingress_from_sg_sgs, count.index).description
}

####################################
# Partners Ingress Mirth SG/Rules
####################################
# Customer Ingress traffic from anywhere
resource "aws_security_group_rule" "partners_mirth_ingress_ports" {
  count                    = length(var.partners_ingress_open_ports)
  type                     = "ingress"
  from_port                = element(var.partners_ingress_open_ports, count.index)
  to_port                  = element(var.partners_ingress_open_ports, count.index)
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mirth_sg.id
  cidr_blocks              = [ "0.0.0.0/0" ]
  description              = "Allow customer traffic on ports designated for Partners"
}

####################################
# CU Medicine Ingress Mirth SG/Rules
####################################
# Customer Ingress traffic from anywhere
resource "aws_security_group_rule" "cumedicine_mirth_ingress_ports" {
  count                    = length(var.cumedicine_ingress_open_ports)
  type                     = "ingress"
  from_port                = element(var.cumedicine_ingress_open_ports, count.index)
  to_port                  = element(var.cumedicine_ingress_open_ports, count.index)
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mirth_sg.id
  cidr_blocks              = [ "0.0.0.0/0" ]
  description              = "Allow customer traffic on ports designated for CU Medicine"
}

####################################
# Yale Ingress Mirth SG/Rules
####################################
# Customer Ingress traffic from anywhere
resource "aws_security_group_rule" "yale_mirth_ingress_ports" {
  count                    = length(var.yale_ingress_open_ports)
  type                     = "ingress"
  from_port                = element(var.yale_ingress_open_ports, count.index)
  to_port                  = element(var.yale_ingress_open_ports, count.index)
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mirth_sg.id
  cidr_blocks              = [ "0.0.0.0/0" ]
  description              = "Allow customer traffic on ports designated for Yale"
}

########################################################
# SG for Firehose Stream
########################################################
# Port 443 for ElasticSearch service
resource "aws_security_group" "firehose_stream_sg" {
  name        = "CMXTrafficCop-${var.environment}-firehose_stream_sg"
  description = "Firehose Delivery Stream security group"

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Traffic Cop SG - firehose_stream_sg"
      Type = "firehose_stream_sg"
    }
  )
}

# Port 443 Egress to ElasticSearch
resource "aws_security_group_rule" "egress_firehose_stream_443_to_ES_cluster" {
  type                     = "egress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.firehose_stream_sg.id
  source_security_group_id = aws_security_group.elasticsearch_sg.id
  description              = "Allow the Firehose send data stream to Elasticsearch cluster on port 443"
}

resource "aws_security_group" "rotate_elasticsearch_index_lambda_function_sg" {
  for_each = var.elasticsearch_index_rotation
  name                   = "CMXTrafficCop-${var.environment}-${each.key}-rotate_elasticsearch_index_lambda_function_sg"
  description            = "Elasticsearch ${each.key} lamnda function security group"
  vpc_id                 = local.vpc_for_es_rotation_lambda[each.key]
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Traffic Cop SG - ${each.key}-rotate_elasticsearch_index_lambda_function_sg"
      Type = "${each.key}-rotate_elasticsearch_index_lambda_function_sg"
    }
  )

  # Egress to the outside world
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
