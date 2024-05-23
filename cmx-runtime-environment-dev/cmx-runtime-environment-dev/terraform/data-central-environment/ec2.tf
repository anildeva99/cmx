#############
# Dundas ASG
#############
resource "aws_launch_template" "dundas_launch_template" {
  name_prefix   = "CodametrixDataCentral-${var.environment}-dundas"
  image_id      = lookup(var.dundas_amis, var.aws_region)
  instance_type = var.dundas_instance_type
  vpc_security_group_ids = [aws_security_group.environment_dundas_sg.id]
  key_name      = aws_key_pair.dundas_key_pair.key_name

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "CodametrixDataCentral-${var.environment}-dundas"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.dundas_instance_profile.name
  }
}

resource "aws_autoscaling_group" "dundas_autoscaling_group" {
  name                = "CodaMetrixDataCentral-${var.environment}-dundas_autoscaling_group"
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  desired_capacity   = lookup(var.dundas_autoscaling_group, "desired_capacity")
  max_size           = lookup(var.dundas_autoscaling_group, "max_size")
  min_size           = lookup(var.dundas_autoscaling_group, "min_size")
  target_group_arns      = [aws_alb_target_group.dundas_alb_target_group.arn]

  launch_template {
    id      = aws_launch_template.dundas_launch_template.id
    version = aws_launch_template.dundas_launch_template.latest_version
  }

  tags = concat([
    for key in keys(var.shared_resource_tags): {
      key                 = key
      value               = var.shared_resource_tags[key]
      propagate_at_launch = true
    }
  ],
  [
    {
      key                 = "Name"
      value               = "CodaMetrix Data Central EC2 - dundas_autoscaling_group"
      propagate_at_launch = false
    },
    {
      key                 = "ConfigSecret"
      value               = var.dundas_config_secret_name
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Type"
      value               = "dundas_autoscaling_group",
      propagate_at_launch = true
    }
  ])
}
