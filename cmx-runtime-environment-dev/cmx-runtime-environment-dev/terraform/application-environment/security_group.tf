
resource "aws_security_group" "application_control_plane_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-application_control_plane_sg"
  description            = "EKS Control Plane security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_control_plane_sg"
      Type = "application_control_plane_sg"
    }
  )
}

# Egress to worker nodes
resource "aws_security_group_rule" "application_control_plane_egress_to_worker_node" {
  type                     = "egress"
  from_port                = "1025"
  to_port                  = "65535"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_control_plane_sg.id
  source_security_group_id = aws_security_group.application_worker_node_sg.id
  description              = "Allow the cluster control plane to communicate with worker nodes"
}

# Port 443 Egress to worker nodes
resource "aws_security_group_rule" "application_control_plane_443_to_worker_node" {
  type                     = "egress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_control_plane_sg.id
  source_security_group_id = aws_security_group.application_worker_node_sg.id
  description              = "Allow the cluster control plane to communicate with pods running extension API servers on port 443"
}

# Port 443 Ingress from the worker nodes
resource "aws_security_group_rule" "application_control_plane_443_from_worker_node" {
  type                     = "ingress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_control_plane_sg.id
  source_security_group_id = aws_security_group.application_worker_node_sg.id
  description              = "Allow pods to communicate with the cluster API Server"
}

resource "aws_security_group" "application_worker_node_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-application_worker_node_sg"
  description            = "EKS Worker Node security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name                                        = "CodaMetrix Application SG - application_worker_node_sg"
      Type                                        = "application_worker_node_sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
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

# All Ports Ingress from the control plane
# !!! I don't like having to do this, but after upgrading to istio 1.3.4, pods were failing to
# !!! be created because the istio-proxy container couldn't be injected, apparently because of
# !!! port restrictions.
# !!! Was seeing something like the following: https://github.com/istio/istio/issues/12456
resource "aws_security_group_rule" "application_worker_node_ingress_from_control_plane_all_ports" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "65535"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_worker_node_sg.id
  source_security_group_id = aws_security_group.application_control_plane_sg.id
  description              = "Allow the cluster control plane to communicate on ANY PORT with worker nodes"
}

# Ingress from the control plane
resource "aws_security_group_rule" "application_worker_node_ingress_from_control_plane" {
  type                     = "ingress"
  from_port                = "1025"
  to_port                  = "65535"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_worker_node_sg.id
  source_security_group_id = aws_security_group.application_control_plane_sg.id
  description              = "Allow the cluster control plane to communicate with worker nodes"
}

# Port 443 Ingress from the control plane
resource "aws_security_group_rule" "application_worker_node_443_from_control_plane" {
  type                     = "ingress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_worker_node_sg.id
  source_security_group_id = aws_security_group.application_control_plane_sg.id
  description              = "Allow pods running extension API servers on port 443 to receive communication from the control plane"
}

# Ingress allowing workers to talk to one another
resource "aws_security_group_rule" "application_worker_node_ingress_from_worker_node" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.application_worker_node_sg.id
  source_security_group_id = aws_security_group.application_worker_node_sg.id
  description              = "Allow pods to communicate with one another"
}

# Allow ingress on all ports from the cmx-automate-ingress security group
resource "aws_security_group_rule" "application_worker_node_ingress_from_cmx_automate_ingress" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.application_worker_node_sg.id
  source_security_group_id = aws_security_group.cmx_automate_ingress_sg.id
  description              = "Allow ingress on all ports from the cmx-automate-ingress security group"
}

# Allow ingress on all ports from the cmx-api-ingress security group
resource "aws_security_group_rule" "application_worker_node_ingress_from_cmx_api_ingress" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.application_worker_node_sg.id
  source_security_group_id = aws_security_group.application_cmx_api_ingress_sg.id
  description              = "Allow ingress on all ports from the cmx-api-ingress security group"
}

# Allow ingress on all ports from the cmx-mirth-connect-api-ingress security group
resource "aws_security_group_rule" "application_worker_node_ingress_from_mirth_connect_api" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.application_worker_node_sg.id
  source_security_group_id = aws_security_group.application_mirth_connect_api_ingress_sg.id
  description              = "Allow ingress on all ports from the cmx-mirth-connect-api-ingress security group"
}

resource "aws_security_group" "application_database_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-application_database_sg"
  description            = "Application database security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_database_sg"
      Type = "application_database_sg"
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

# Port 5432 ingress from K8S worker nodes
resource "aws_security_group_rule" "application_database_ingress_from_worker_nodes" {
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_database_sg.id
  source_security_group_id = aws_security_group.application_worker_node_sg.id
  description              = "Allow worker nodes to communicate with the database"
}

# Port 5432 ingress from bastion host
resource "aws_security_group_rule" "application_database_ingress_from_bastion_host" {
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_database_sg.id
  source_security_group_id = aws_security_group.application_bastion_sg.id
  description              = "Allow bastion host to communicate with the database"
}

# Port 5432 ingress from additional SGs
resource "aws_security_group_rule" "application_database_ingress_from_additional_sgs" {
  count                    = length(var.application_database_additional_ingress_sgs)
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_database_sg.id
  source_security_group_id = element(var.application_database_additional_ingress_sgs, count.index)
  description              = "Allow ${element(var.application_database_additional_ingress_sgs, count.index)} to communicate with the database"
}

resource "aws_security_group" "application_bastion_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-application_bastion_sg"
  description            = "Application bastion host security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_bastion_sg"
      Type = "application_bastion_sg"
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

resource "aws_security_group_rule" "application_bastion_ingress_from_cidr" {
  count             = length(var.application_bastion_ingress_from_cidr_sgs)
  type              = "ingress"
  from_port         = element(var.application_bastion_ingress_from_cidr_sgs, count.index).from_port
  to_port           = element(var.application_bastion_ingress_from_cidr_sgs, count.index).to_port
  protocol          = element(var.application_bastion_ingress_from_cidr_sgs, count.index).protocol
  security_group_id = aws_security_group.application_bastion_sg.id
  cidr_blocks       = element(var.application_bastion_ingress_from_cidr_sgs, count.index).cidr_blocks
  description       = element(var.application_bastion_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "application_bastion_ingress_from_sg" {
  count                    = length(var.application_bastion_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.application_bastion_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.application_bastion_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.application_bastion_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.application_bastion_sg.id
  source_security_group_id = element(var.application_bastion_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.application_bastion_ingress_from_sg_sgs, count.index).description
}

resource "aws_security_group" "ingress_bastion_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-ingress_bastion_sg"
  description            = "Ingress bastion host security group"
  vpc_id                 = aws_vpc.ingress_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - ingress_bastion_sg"
      Type = "ingress_bastion_sg"
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

resource "aws_security_group_rule" "ingress_bastion_ingress_from_cidr" {
  count             = length(var.ingress_bastion_ingress_from_cidr_sgs)
  type              = "ingress"
  from_port         = element(var.ingress_bastion_ingress_from_cidr_sgs, count.index).from_port
  to_port           = element(var.ingress_bastion_ingress_from_cidr_sgs, count.index).to_port
  protocol          = element(var.ingress_bastion_ingress_from_cidr_sgs, count.index).protocol
  security_group_id = aws_security_group.ingress_bastion_sg.id
  cidr_blocks       = element(var.ingress_bastion_ingress_from_cidr_sgs, count.index).cidr_blocks
  description       = element(var.ingress_bastion_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "ingress_bastion_ingress_from_sg" {
  count                    = length(var.ingress_bastion_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.ingress_bastion_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.ingress_bastion_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.ingress_bastion_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.ingress_bastion_sg.id
  source_security_group_id = element(var.ingress_bastion_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.ingress_bastion_ingress_from_sg_sgs, count.index).description
}

resource "aws_security_group" "application_redis_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-application_redis_sg"
  description            = "Application Redis security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_redis_sg"
      Type = "application_redis_sg"
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

# Port 6379 ingress from K8S worker nodes
resource "aws_security_group_rule" "application_redis_ingress_from_worker_nodes" {
  type                     = "ingress"
  from_port                = "6379"
  to_port                  = "6379"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_redis_sg.id
  source_security_group_id = aws_security_group.application_worker_node_sg.id
  description              = "Allow worker nodes to communicate with Redis"
}

# Port 6379 ingress from bastion host
resource "aws_security_group_rule" "application_redis_ingress_from_bastion_host" {
  type                     = "ingress"
  from_port                = "6379"
  to_port                  = "6379"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_redis_sg.id
  source_security_group_id = aws_security_group.application_bastion_sg.id
  description              = "Allow bastion_host to communicate with Redis"
}

resource "aws_security_group" "application_data_warehouse_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-application_data_warehouse_sg"
  description            = "Application data warehouse security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_data_warehouse_sg"
      Type = "application_data_warehouse_sg"
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

# Port 5439 ingress from bastion host
resource "aws_security_group_rule" "application_data_warehouse_ingress_from_bastion_host" {
  type                     = "ingress"
  from_port                = "5439"
  to_port                  = "5439"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_data_warehouse_sg.id
  source_security_group_id = aws_security_group.application_bastion_sg.id
  description              = "Allow bastion host to communicate with the data warehouse"
}

# Port 5439 ingress from additional SGs
resource "aws_security_group_rule" "application_data_warehouse_ingress_from_additional_sgs" {
  count                    = length(var.application_data_warehouse_additional_ingress_sgs)
  type                     = "ingress"
  from_port                = "5439"
  to_port                  = "5439"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_data_warehouse_sg.id
  source_security_group_id = element(var.application_data_warehouse_additional_ingress_sgs, count.index)
  description              = "Allow ${element(var.application_data_warehouse_additional_ingress_sgs, count.index)} to communicate with the data warehouse"
}

resource "aws_security_group_rule" "application_data_warehouse_ingress_from_additional_cidr_sgs" {
  count             = length(var.application_data_warehouse_additional_ingress_cidr_sgs)
  type              = "ingress"
  from_port         = "5439"
  to_port           = "5439"
  protocol          = "tcp"
  security_group_id = aws_security_group.application_data_warehouse_sg.id
  cidr_blocks       = [element(var.application_data_warehouse_additional_ingress_cidr_sgs, count.index)]
  description       = "Allow ${element(var.application_data_warehouse_additional_ingress_cidr_sgs, count.index)} to communicate with the data warehouse"
}

# Port 5439 ingress from EMR (Spark) master
resource "aws_security_group_rule" "application_data_warehouse_ingress_from_emr_master" {
  type                     = "ingress"
  from_port                = "5439"
  to_port                  = "5439"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_data_warehouse_sg.id
  source_security_group_id = aws_security_group.application_dw_emr_master_security_group.id
  description              = "Allow EMR master to communicate with the data warehouse"
}

# Port 5439 ingress from EMR (Spark) core instances
resource "aws_security_group_rule" "application_data_warehouse_ingress_from_emr_core" {
  type                     = "ingress"
  from_port                = "5439"
  to_port                  = "5439"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_data_warehouse_sg.id
  source_security_group_id = aws_security_group.application_dw_emr_core_security_group.id
  description              = "Allow EMR core instances to communicate with the data warehouse"
}

# Port 443 for application ElasticSearch service
resource "aws_security_group" "application_elasticsearch_sg" {
  name        = "CodaMetrixApplication-${var.environment}-application_elasticsearch_sg"
  description = "Application Elasticsearch security group"

  # ElasticSearch will live in the application VPC...
  vpc_id = aws_vpc.application_vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_elasticsearch_sg"
      Type = "application_elasticsearch_sg"
    }
  )

  ingress {
    description = "HTTPS access within the application VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_vpc.application_vpc.cidr_block}",
    ]
  }

  ingress {
    description = "API acccess within the application VPC"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_vpc.application_vpc.cidr_block}",
    ]
  }
}

resource "aws_security_group" "ingress_customer_networking_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-ingress_customer_networking_sg"
  description            = "Customer VPN security group"
  vpc_id                 = aws_vpc.ingress_vpc.id
  revoke_rules_on_delete = true

  tags = {
    Usage       = "CodaMetrix Application"
    Name        = "CodaMetrix Application SG - ingress_customer_networking_sg"
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
resource "aws_security_group_rule" "ingress_customer_networking_ingress_from_bastion_host" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ingress_customer_networking_sg.id
  source_security_group_id = aws_security_group.ingress_bastion_sg.id
  description              = "Allow bastion host to communicate with the customer VPN"
}

# UDP Port 500 (ISAKMP) ingress from the outside world
resource "aws_security_group_rule" "ingress_customer_networking_isakmp" {
  type              = "ingress"
  from_port         = "500"
  to_port           = "500"
  protocol          = "udp"
  security_group_id = aws_security_group.ingress_customer_networking_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow ISAKMP ingress from the outside world"
}

# UDP Port 4500 (IPSEC) ingress from the outside world
resource "aws_security_group_rule" "ingress_customer_networking_ipsec" {
  type              = "ingress"
  from_port         = "4500"
  to_port           = "4500"
  protocol          = "udp"
  security_group_id = aws_security_group.ingress_customer_networking_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow IPSEC ingress from the outside world"
}

# IP protocol 50 (Encapsulating Security Payload) ingress from the outside world
resource "aws_security_group_rule" "ingress_customer_networking_esp" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "50"
  security_group_id = aws_security_group.ingress_customer_networking_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow ESP ingress from the outside world"
}

# IP protocol 51 (Authentication Header) ingress from the outside world
resource "aws_security_group_rule" "ingress_customer_networking_ah" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "51"
  security_group_id = aws_security_group.ingress_customer_networking_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow AH ingress from the outside world"
}

resource "aws_security_group_rule" "ingress_customer_networking_icmp" {
  type              = "ingress"
  from_port         = "-1"
  to_port           = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.ingress_customer_networking_sg.id
  cidr_blocks       = ["${var.ingress_vpc_subnet_cidr_block_prefix}.0.0/16"]
  description       = "Allow all ICMP ingress from the ingress network"
}

# Ingress traffic from the Partners Mirth channels
resource "aws_security_group_rule" "ingress_customer_networking_partners_ports" {
  count                    = length(var.partners_ingress_open_ports)
  type                     = "ingress"
  from_port                = element(var.partners_ingress_open_ports, count.index)
  to_port                  = element(var.partners_ingress_open_ports, count.index)
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ingress_customer_networking_sg.id
  source_security_group_id = aws_security_group.ingress_mirth_sg.id
  description              = "Allow tcp port ${element(var.partners_ingress_open_ports, count.index)} ingress from the Partners Mirth channel"
}

# Ingress traffic from the CU Medicine Mirth channels
resource "aws_security_group_rule" "ingress_customer_networking_cumedicine_ports" {
  count                    = length(var.cumedicine_ingress_open_ports)
  type                     = "ingress"
  from_port                = element(var.cumedicine_ingress_open_ports, count.index)
  to_port                  = element(var.cumedicine_ingress_open_ports, count.index)
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ingress_customer_networking_sg.id
  source_security_group_id = aws_security_group.ingress_mirth_sg.id
  description              = "Allow tcp port ${element(var.cumedicine_ingress_open_ports, count.index)} ingress from the CU Medicine Mirth channel"
}

# !!! Ingress traffic from Mirth - All Ports !!!
# !!! I hate to have to do this but for some reason, both Colorado and Partners have had issues (traffic working in one direction, but not both)
# !!! without this rule in place. We should remove this as soon as we can figure out how.
resource "aws_security_group_rule" "ingress_customer_networking_all_ports_from_ingress_mirth" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ingress_customer_networking_sg.id
  source_security_group_id = aws_security_group.ingress_mirth_sg.id
  description              = "!!! Danger - Allow ALL tcp port ingress from ingress Mirth"
}

##########################################################
# Securiy Groups for EMR cluster
##########################################################
resource "aws_security_group" "application_dw_emr_master_security_group" {
  name                   = "CMXApp-${var.environment}-application_dw_emr_master_security_group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = "true"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_dw_emr_master_security_group"
      Type = "application_dw_emr_master_security_group"
    }
  )
}

# According to https://forums.aws.amazon.com/ann.jspa?annID=2347, allow SNS known ingress trafffic
resource "aws_security_group_rule" "application_dw_emr_sns_source_addresses" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = var.sns_source_addresses
  security_group_id = aws_security_group.application_dw_emr_master_security_group.id
}

# Port 22 (SSH) ingress from bastion host
resource "aws_security_group_rule" "application_dw_emr_master_ssh_from_bastion_host" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_dw_emr_master_security_group.id
  source_security_group_id = aws_security_group.application_bastion_sg.id
  description              = "Allow SSH from the bastion host"
}

resource "aws_security_group" "application_dw_emr_core_security_group" {
  name                   = "CMXApp-${var.environment}-application_dw_emr_core_security_group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = "true"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_dw_emr_core_security_group"
      Type = "application_dw_emr_core_security_group"
    }
  )
}

# Port 22 (SSH) ingress from bastion host
resource "aws_security_group_rule" "application_dw_emr_core_ssh_from_bastion_host" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_dw_emr_core_security_group.id
  source_security_group_id = aws_security_group.application_bastion_sg.id
  description              = "Allow SSH from the bastion host"
}

resource "aws_security_group" "application_dw_emr_service_access_security_group" {
  name                   = "CMXApp-${var.environment}-application_dw_emr_service_access_security_group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = "true"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_dw_emr_service_access_security_group"
      Type = "application_dw_emr_service_access_security_group"
    }
  )
}

# Port 9443 ingress from managed master
resource "aws_security_group_rule" "application_dw_emr_service_ingress_from_managed_master" {
  type                     = "ingress"
  from_port                = "9443"
  to_port                  = "9443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_dw_emr_service_access_security_group.id
  source_security_group_id = aws_security_group.application_dw_emr_master_security_group.id
  description              = "Allow 9443 from the managed master"
}

##########################################################
# Securiy Groups for MSK ckuster
##########################################################

resource "aws_security_group" "application_msk_sg" {
  name                   = "CMXApp-${var.environment}-application_msk_sg"
  description            = "Application Kafka cluster security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_msk_sg"
      Type = "application-msk-sg"
    }
  )
}


resource "aws_security_group_rule" "allow_ingress_from_emr_master_node" {
  security_group_id        = aws_security_group.application_msk_sg.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.application_dw_emr_master_security_group.id
}


resource "aws_security_group_rule" "allow_ingress_from_emr_core_code" {
  security_group_id        = aws_security_group.application_msk_sg.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.application_dw_emr_core_security_group.id
}

resource "aws_security_group_rule" "allow_ingress_from_worker_nodes" {
  security_group_id        = aws_security_group.application_msk_sg.id
  from_port                = "9094"
  to_port                  = "9094"
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.application_worker_node_sg.id
}

resource "aws_security_group_rule" "allow_ingress_from_zookeeper" {
  security_group_id        = aws_security_group.application_msk_sg.id
  from_port                = "2081"
  to_port                  = "2081"
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.application_worker_node_sg.id
}

resource "aws_security_group_rule" "allow_ingress_from_bastion_host_to_kafka" {
  security_group_id        = aws_security_group.application_msk_sg.id
  from_port                = element(split(":", element(split(",", "${aws_msk_cluster.application_data_warehouse_msk_cluster.bootstrap_brokers_tls}"), 0)), 1)
  to_port                  = element(split(":", element(split(",", "${aws_msk_cluster.application_data_warehouse_msk_cluster.bootstrap_brokers_tls}"), 0)), 1)
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.application_bastion_sg.id
}

resource "aws_security_group_rule" "allow_ingress_to_zookeeper_from_bastion_host" {
  security_group_id        = aws_security_group.application_msk_sg.id
  from_port                = element(split(":", element(split(",", "${aws_msk_cluster.application_data_warehouse_msk_cluster.zookeeper_connect_string}"), 0)), 1)
  to_port                  = element(split(":", element(split(",", "${aws_msk_cluster.application_data_warehouse_msk_cluster.zookeeper_connect_string}"), 0)), 1)
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.application_bastion_sg.id
}

#####################################################

##################
# Ingress Mirth
##################
resource "aws_security_group" "ingress_mirth_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-ingress_mirth_sg"
  description            = "Customer Mirth security group"
  vpc_id                 = aws_vpc.ingress_vpc.id
  revoke_rules_on_delete = true

  tags = {
    Usage       = "CodaMetrix Application"
    Name        = "CodaMetrix Application SG - ingress_mirth_sg"
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
resource "aws_security_group_rule" "ingress_mirth_ingress_from_bastion_host" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ingress_mirth_sg.id
  source_security_group_id = aws_security_group.ingress_bastion_sg.id
  description              = "Allow ingress bastion host to communicate with ingress mirth"
}

resource "aws_security_group_rule" "ingress_mirth_connect_api_ingress_from_cidr" {
  count             = length(var.ingress_mirth_connect_api_ingress_from_cidr_sgs)
  type              = "ingress"
  from_port         = element(var.ingress_mirth_connect_api_ingress_from_cidr_sgs, count.index).from_port
  to_port           = element(var.ingress_mirth_connect_api_ingress_from_cidr_sgs, count.index).to_port
  protocol          = element(var.ingress_mirth_connect_api_ingress_from_cidr_sgs, count.index).protocol
  security_group_id = aws_security_group.ingress_mirth_sg.id
  cidr_blocks       = element(var.ingress_mirth_connect_api_ingress_from_cidr_sgs, count.index).cidr_blocks
  description       = element(var.ingress_mirth_connect_api_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "ingress_mirth_connect_api_ingress_from_sg" {
  count                    = length(var.ingress_mirth_connect_api_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.ingress_mirth_connect_api_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.ingress_mirth_connect_api_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.ingress_mirth_connect_api_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.ingress_mirth_sg.id
  source_security_group_id = element(var.ingress_mirth_connect_api_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.ingress_mirth_connect_api_ingress_from_sg_sgs, count.index).description
}

# Ingress traffic from application Mirth
# !!! Note, opening these up from anywhere for now... should be locked down to application Mirth (EKS worker nodes)
resource "aws_security_group_rule" "app_mirth_to_ingress_mirth_open_ports" {
  count             = length(var.app_mirth_to_ingress_mirth_open_ports)
  type              = "ingress"
  from_port         = element(var.app_mirth_to_ingress_mirth_open_ports, count.index)
  to_port           = element(var.app_mirth_to_ingress_mirth_open_ports, count.index)
  protocol          = "tcp"
  security_group_id = aws_security_group.ingress_mirth_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow tcp port ${element(var.app_mirth_to_ingress_mirth_open_ports, count.index)} ingress from set of additional ports"
}

# Ingress traffic from set of additional open ports
# !!! Note, opening these up from anywhere for now... mostly these are used for inter-environment traffic
resource "aws_security_group_rule" "ingress_mirth_additional_open_ports" {
  count             = length(var.ingress_mirth_additional_open_ports)
  type              = "ingress"
  from_port         = element(var.ingress_mirth_additional_open_ports, count.index)
  to_port           = element(var.ingress_mirth_additional_open_ports, count.index)
  protocol          = "tcp"
  security_group_id = aws_security_group.ingress_mirth_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow tcp port ${element(var.ingress_mirth_additional_open_ports, count.index)} ingress from set of additional ports"
}
####################################
# CU Medicine Ingress Mirth SG/Rules
####################################
# Customer Ingress traffic from anywhere
resource "aws_security_group_rule" "partners_mirth_ingress_ports" {
  count             = length(var.partners_ingress_open_ports)
  type              = "ingress"
  from_port         = element(var.partners_ingress_open_ports, count.index)
  to_port           = element(var.partners_ingress_open_ports, count.index)
  protocol          = "tcp"
  security_group_id = aws_security_group.ingress_mirth_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow customer traffic on ports designated for Partners"
}

####################################
# CU Medicine Ingress Mirth SG/Rules
####################################
# Customer Ingress traffic from anywhere
resource "aws_security_group_rule" "cumedicine_mirth_ingress_ports" {
  count             = length(var.cumedicine_ingress_open_ports)
  type              = "ingress"
  from_port         = element(var.cumedicine_ingress_open_ports, count.index)
  to_port           = element(var.cumedicine_ingress_open_ports, count.index)
  protocol          = "tcp"
  security_group_id = aws_security_group.ingress_mirth_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow customer traffic on ports designated for CU Medicine"
}

########################################################
# SG for Firehose Stream
########################################################
# Port 443 for application ElasticSearch service
resource "aws_security_group" "application_firehose_stream_sg" {
  name        = "CodaMetrixApplication-${var.environment}-application_firehose_stream_sg"
  description = "Application Firehose Delivery Stream security group"

  vpc_id = aws_vpc.application_vpc.id

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_firehose_stream_sg"
      Type = "application_firehose_stream_sg"
    }
  )
}

# Port 443 Egress to ElasticSearch
resource "aws_security_group_rule" "egress_firehose_stream_443_to_ES_cluster" {
  type                     = "egress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application_firehose_stream_sg.id
  source_security_group_id = aws_security_group.application_elasticsearch_sg.id
  description              = "Allow the Firehose send data stream to Elasticsearch cluster on port 443"
}

###############################################################################################################
# Security group for cmx-automate-ingress - K8S Ingress/ALB which handles external HTTP(s) into the application
###############################################################################################################
resource "aws_security_group" "cmx_automate_ingress_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-cmx_automate_ingress_sg"
  description            = "Application cmx-automate-ingress ALB security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - cmx_automate_ingress_sg"
      Type = "cmx_automate_ingress_sg"
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

resource "aws_security_group_rule" "cmx_automate_ingress_http_from_application_network" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.cmx_automate_ingress_sg.id
  cidr_blocks       = [var.vpc_cidr_block]
  description       = "Allow HTTP from the application network"
}

resource "aws_security_group_rule" "cmx_automate_ingress_https_from_application_network" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cmx_automate_ingress_sg.id
  cidr_blocks       = [var.vpc_cidr_block]
  description       = "Allow HTTPS from the application network"
}

resource "aws_security_group_rule" "cmx_automate_ingress_from_cidr" {
  count             = length(var.cmx_automate_ingress_from_cidr_sgs)
  type              = "ingress"
  from_port         = element(var.cmx_automate_ingress_from_cidr_sgs, count.index).from_port
  to_port           = element(var.cmx_automate_ingress_from_cidr_sgs, count.index).to_port
  protocol          = element(var.cmx_automate_ingress_from_cidr_sgs, count.index).protocol
  security_group_id = aws_security_group.cmx_automate_ingress_sg.id
  cidr_blocks       = element(var.cmx_automate_ingress_from_cidr_sgs, count.index).cidr_blocks
  description       = element(var.cmx_automate_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "cmx_automate_ingress_from_sg" {
  count                    = length(var.cmx_automate_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.cmx_automate_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.cmx_automate_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.cmx_automate_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.cmx_automate_ingress_sg.id
  source_security_group_id = element(var.cmx_automate_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.cmx_automate_ingress_from_sg_sgs, count.index).description
}

#################################################################################################
# Security group for cmx-api-ingress - K8S Ingress/ALB which handles HTTP(s) into the application
#################################################################################################
resource "aws_security_group" "application_cmx_api_ingress_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-application_cmx_api_ingress_sg"
  description            = "Application cmx-api-ingress ALB security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_cmx_api_ingress_sg"
      Type = "application_cmx_api_ingress_sg"
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

resource "aws_security_group" "application_cmx_api_public_whitelist_ingress_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-application_cmx_api_public_whitelist_ingress_sg"
  description            = "Application cmx-api-ingress Public Whitelist ALB security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_cmx_api_public_whitelist_ingress_sg"
      Type = "application_cmx_api_public_whitelist_ingress_sg"
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

resource "aws_security_group_rule" "application_cmx_api_public_ingress_http_from_whitelist" {
  count             = length(var.cmx_api_public_whitelist) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.application_cmx_api_public_whitelist_ingress_sg.id
  cidr_blocks       = var.cmx_api_public_whitelist
  description       = "Allow HTTP from the whitelisted ip addresses"
}

resource "aws_security_group_rule" "application_cmx_api_public_ingress_https_from_whitelist" {
  count             = length(var.cmx_api_public_whitelist) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.application_cmx_api_public_whitelist_ingress_sg.id
  cidr_blocks       = var.cmx_api_public_whitelist
  description       = "Allow HTTPS from the whitelisted ip addresses"
}

resource "aws_security_group_rule" "application_worker_node_ingress_from_cmx_api_public_whitelist_ingress" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.application_worker_node_sg.id
  source_security_group_id = aws_security_group.application_cmx_api_public_whitelist_ingress_sg.id
  description              = "Allow ingress on all ports from the cmx-api-public-whitelist-ingress security group"
}

resource "aws_security_group_rule" "application_cmx_api_ingress_http_from_application_network" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.application_cmx_api_ingress_sg.id
  cidr_blocks       = [var.vpc_cidr_block]
  description       = "Allow HTTP from the application network"
}

resource "aws_security_group_rule" "application_cmx_api_ingress_https_from_application_network" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.application_cmx_api_ingress_sg.id
  cidr_blocks       = [var.vpc_cidr_block]
  description       = "Allow HTTPS from the application network"
}

resource "aws_security_group_rule" "application_cmx_api_ingress_from_cidr" {
  count             = length(var.application_cmx_api_ingress_from_cidr_sgs)
  type              = "ingress"
  from_port         = element(var.application_cmx_api_ingress_from_cidr_sgs, count.index).from_port
  to_port           = element(var.application_cmx_api_ingress_from_cidr_sgs, count.index).to_port
  protocol          = element(var.application_cmx_api_ingress_from_cidr_sgs, count.index).protocol
  security_group_id = aws_security_group.application_cmx_api_ingress_sg.id
  cidr_blocks       = element(var.application_cmx_api_ingress_from_cidr_sgs, count.index).cidr_blocks
  description       = element(var.application_cmx_api_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "application_cmx_api_ingress_from_sg" {
  count                    = length(var.application_cmx_api_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.application_cmx_api_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.application_cmx_api_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.application_cmx_api_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.application_cmx_api_ingress_sg.id
  source_security_group_id = element(var.application_cmx_api_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.application_cmx_api_ingress_from_sg_sgs, count.index).description
}

#####################################################################################################################################
# Security group for cmx-mirth-connect-api-ingress - K8S Ingress/ALB which handles Mirth Connect HTTPS traffic in the application cluster
#####################################################################################################################################
resource "aws_security_group" "application_mirth_connect_api_ingress_sg" {
  name                   = "CodaMetrixApplication-${var.environment}-application_mirth_connect_api_ingress_sg"
  description            = "Application cmx-mirth-connect-api-ingress ALB security group"
  vpc_id                 = aws_vpc.application_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - application_mirth_connect_api_ingress_sg"
      Type = "application_mirth_connect_api_ingress_sg"
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

resource "aws_security_group_rule" "application_mirth_connect_api_ingress_http_from_application_network" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.application_mirth_connect_api_ingress_sg.id
  cidr_blocks       = [var.vpc_cidr_block]
  description       = "Allow HTTP from the application network"
}

resource "aws_security_group_rule" "application_mirth_connect_api_ingress_https_from_application_network" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  security_group_id = aws_security_group.application_mirth_connect_api_ingress_sg.id
  cidr_blocks       = [var.vpc_cidr_block]
  description       = "Allow HTTPS from the application network"
}

resource "aws_security_group_rule" "application_mirth_connect_api_ingress_from_cidr" {
  count             = length(var.application_mirth_connect_api_ingress_from_cidr_sgs)
  type              = "ingress"
  from_port         = element(var.application_mirth_connect_api_ingress_from_cidr_sgs, count.index).from_port
  to_port           = element(var.application_mirth_connect_api_ingress_from_cidr_sgs, count.index).to_port
  protocol          = element(var.application_mirth_connect_api_ingress_from_cidr_sgs, count.index).protocol
  security_group_id = aws_security_group.application_mirth_connect_api_ingress_sg.id
  cidr_blocks       = element(var.application_mirth_connect_api_ingress_from_cidr_sgs, count.index).cidr_blocks
  description       = element(var.application_mirth_connect_api_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "application_mirth_connect_api_ingress_from_sg" {
  count                    = length(var.application_mirth_connect_api_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.application_mirth_connect_api_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.application_mirth_connect_api_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.application_mirth_connect_api_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.application_mirth_connect_api_ingress_sg.id
  source_security_group_id = element(var.application_mirth_connect_api_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.application_mirth_connect_api_ingress_from_sg_sgs, count.index).description
}

resource "aws_security_group" "rotate_elasticsearch_index_lambda_function_sg" {
  for_each               = var.elasticsearch_index_rotation
  name                   = "CodaMetrixApplication-${var.environment}-${each.key}-rotate_elasticsearch_index_lambda_function_sg"
  description            = "Elasticsearch ${each.key} lamnda function security group"
  vpc_id                 = local.vpc_for_es_rotation_lambda[each.key]
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Application SG - ${each.key}-rotate_elasticsearch_index_lambda_function_sg"
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

#########
# Outputs
#########
output "application_control_plane_sg_arn" {
  value = aws_security_group.application_control_plane_sg.arn
}

output "application_worker_node_sg_arn" {
  value = aws_security_group.application_worker_node_sg.arn
}

output "application_database_sg_arn" {
  value = aws_security_group.application_database_sg.arn
}

output "application_redis_sg_arn" {
  value = aws_security_group.application_redis_sg.arn
}

output "application_bastion_sg_arn" {
  value = aws_security_group.application_bastion_sg.arn
}

output "application_data_warehouse_sg_arn" {
  value = aws_security_group.application_data_warehouse_sg.arn
}

output "application_elasticsearch_sg_arn" {
  value = aws_security_group.application_elasticsearch_sg.arn
}

output "ingress_bastion_sg_arn" {
  value = aws_security_group.ingress_bastion_sg.arn
}
