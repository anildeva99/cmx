resource "aws_security_group" "environment_bastion_sg" {
  name                   = "CodaMetrixDataCentral-${var.environment}-environment_bastion_sg"
  description            = "Environment bastion host security group"
  vpc_id                 = aws_vpc.environment_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central SG - environment_bastion_sg"
      Type = "environment_bastion_sg"
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

resource "aws_security_group_rule" "environment_bastion_ingress_from_cidr" {
  count                    = length(var.bastion_ingress_from_cidr_sgs)
  type                     = "ingress"
  from_port                = element(var.bastion_ingress_from_cidr_sgs, count.index).from_port
  to_port                  = element(var.bastion_ingress_from_cidr_sgs, count.index).to_port
  protocol                 = element(var.bastion_ingress_from_cidr_sgs, count.index).protocol
  security_group_id        = aws_security_group.environment_bastion_sg.id
  cidr_blocks              = element(var.bastion_ingress_from_cidr_sgs, count.index).cidr_blocks
  description              = element(var.bastion_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "environment_bastion_ingress_from_sg" {
  count                    = length(var.bastion_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.bastion_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.bastion_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.bastion_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.environment_bastion_sg.id
  source_security_group_id = element(var.bastion_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.bastion_ingress_from_sg_sgs, count.index).description
}

##########################
# Dundas Security Groups
##########################
resource "aws_security_group" "alb_dundas_sg" {
  name                   = "CodaMetrixDataCentral-${var.environment}-alb_dundas_sg"
  description            = "ALB dundas security group"
  vpc_id                 = aws_vpc.environment_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central SG - alb_dundas_sg"
      Type = "alb_dundas_sg"
    }
  )

  # HTTPS to Dundas
  egress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    security_groups    = [aws_security_group.environment_dundas_sg.id]
  }
}

resource "aws_security_group_rule" "alb_dundas_ingress_from_cidr" {
  count                    = length(var.alb_dundas_ingress_from_cidr_sgs)
  type                     = "ingress"
  from_port                = element(var.alb_dundas_ingress_from_cidr_sgs, count.index).from_port
  to_port                  = element(var.alb_dundas_ingress_from_cidr_sgs, count.index).to_port
  protocol                 = element(var.alb_dundas_ingress_from_cidr_sgs, count.index).protocol
  security_group_id        = aws_security_group.alb_dundas_sg.id
  cidr_blocks              = element(var.alb_dundas_ingress_from_cidr_sgs, count.index).cidr_blocks
  description              = element(var.alb_dundas_ingress_from_cidr_sgs, count.index).description
}

resource "aws_security_group_rule" "alb_dundas_ingress_from_sg" {
  count                    = length(var.alb_dundas_ingress_from_sg_sgs)
  type                     = "ingress"
  from_port                = element(var.alb_dundas_ingress_from_sg_sgs, count.index).from_port
  to_port                  = element(var.alb_dundas_ingress_from_sg_sgs, count.index).to_port
  protocol                 = element(var.alb_dundas_ingress_from_sg_sgs, count.index).protocol
  security_group_id        = aws_security_group.alb_dundas_sg.id
  source_security_group_id = element(var.alb_dundas_ingress_from_sg_sgs, count.index).source_security_group_id
  description              = element(var.alb_dundas_ingress_from_sg_sgs, count.index).description
}

resource "aws_security_group" "environment_dundas_sg" {
  name                   = "CodaMetrixDataCentral-${var.environment}-environment_dundas_sg"
  description            = "Environment Dundas security group"
  vpc_id                 = aws_vpc.environment_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central SG - environment_dundas_sg"
      Type = "environment_dundas_sg"
    }
  )

  # Anything to anywhere
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SSH From Bastion to Dundas
resource "aws_security_group_rule" "dundas_ingress_from_bastion" {
  type                     = "ingress"
  from_port                = "3389"
  to_port                  = "3389"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.environment_dundas_sg.id
  source_security_group_id = aws_security_group.environment_bastion_sg.id
  description              = "Allow Bastion RDP to Dundas"
}

# HTTPS from ALB to Dundas
resource "aws_security_group_rule" "dundas_ingress_from_alb" {
  type                     = "ingress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.environment_dundas_sg.id
  source_security_group_id = aws_security_group.alb_dundas_sg.id
  description              = "Allow Dundas ALB to Dundas"
}

# Port 5432 ingress from Dundas App DB
resource "aws_security_group_rule" "dundas_ingress_from_dundas_database" {
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.environment_dundas_sg.id
  source_security_group_id = aws_security_group.dundas_database_sg.id
  description              = "Allow Dundas databases to communicate with Dundas"
}

resource "aws_security_group" "dundas_database_sg" {
  name                   = "CodaMetrixDataCentral-${var.environment}-dundas_database_sg"
  description            = "Dundas application and warehouse database security group"
  vpc_id                 = aws_vpc.environment_vpc.id
  revoke_rules_on_delete = true

  tags = merge(
    var.shared_resource_tags,
    {
      Name = "CodaMetrix Data Central SG - dundas_database_sg"
      Type = "dundas_database_sg"
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

# Port 5432 ingress from Dundas Instances
resource "aws_security_group_rule" "dundas_database_ingress_from_dundas" {
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dundas_database_sg.id
  source_security_group_id = aws_security_group.environment_dundas_sg.id
  description              = "Allow Dundas to communicate with the Dundas databases"
}

# Port 5432 ingress from bastion host
resource "aws_security_group_rule" "dundas_database_ingress_from_bastion_host" {
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dundas_database_sg.id
  source_security_group_id = aws_security_group.environment_bastion_sg.id
  description              = "Allow bastion host to communicate with the dundas databases"
}

# Port 5432 ingress from additional SGs
resource "aws_security_group_rule" "dundas_database_ingress_from_additional_sgs" {
  count                    = length(var.dundas_application_database_additional_ingress_sgs)
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dundas_database_sg.id
  source_security_group_id = element(var.dundas_application_database_additional_ingress_sgs, count.index)
  description              = "Allow ${element(var.dundas_application_database_additional_ingress_sgs, count.index)} to communicate with the database"
}
