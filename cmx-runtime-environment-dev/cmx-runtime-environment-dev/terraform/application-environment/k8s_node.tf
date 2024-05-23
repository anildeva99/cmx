resource "aws_autoscaling_group" "application_worker_node_asg" {
  name                 = "CodaMetrixApplication-${var.environment}-application_worker_node_asg-${aws_launch_template.application_worker_node_launchtemplate.name}"
  max_size             = var.node_asg_max_size
  min_size             = var.node_asg_min_size
  health_check_type    = "EC2"
  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  termination_policies = ["OldestInstance", "OldestLaunchConfiguration"]

  launch_template {
    name    = aws_launch_template.application_worker_node_launchtemplate.name
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = concat([
    for key in keys(var.shared_resource_tags) : {
      key                 = key
      value               = var.shared_resource_tags[key]
      propagate_at_launch = true
    }
    ],
    [
      {
        key                 = "Usage"
        value               = "CodaMetrix Application"
        propagate_at_launch = true
      },
      {
        key                 = "Name"
        value               = "${var.cluster_name}-${var.node_group_name}-worker_node"
        propagate_at_launch = true
      },
      {
        key                 = "Environment"
        value               = var.environment
        propagate_at_launch = true
      },
      {
        key                 = "Type"
        value               = "worker_node"
        propagate_at_launch = true
      },
      {
        key                 = "kubernetes.io/cluster/${var.cluster_name}"
        value               = "owned"
        propagate_at_launch = true
      },
      {
        key                 = "k8s.io/cluster-autoscaler/enabled"
        value               = "true"
        propagate_at_launch = false
      },
      {
        key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
        value               = "owned"
        propagate_at_launch = false
      }
  ])
}

resource "aws_launch_template" "application_worker_node_launchtemplate" {
  name_prefix   = "CodaMetrixApplication-${var.environment}-application_worker_node_launchtemplate-"
  image_id      = lookup(var.node_amis, var.aws_region)
  instance_type = var.node_instance_type
  iam_instance_profile { name = aws_iam_instance_profile.eks_node_instance_profile.name }
  vpc_security_group_ids = [aws_security_group.application_worker_node_sg.id]
  key_name               = aws_key_pair.worker_node_key_pair.key_name
  user_data              = data.template_cloudinit_config.application_worker_node_cloudinit.rendered

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp2"
      volume_size           = var.node_volume_size
      delete_on_termination = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.shared_resource_tags,
      {
        Type = "application_worker_node_launchtemplate-instance"
        Name = "CodaMetrix Application EC2 - application_worker_node_launchtemplate-instance"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.shared_resource_tags,
      {
        Type = "application_worker_node_launchtemplate-volume"
        Name = "CodaMetrix Application EC2 - application_worker_node_launchtemplate-volume"
      }
    )
  }
}

output "application_worker_node_asg_arn" {
  value = aws_autoscaling_group.application_worker_node_asg.arn
}

output "application_worker_node_launchtemplate_id" {
  value = aws_launch_template.application_worker_node_launchtemplate.id
}
