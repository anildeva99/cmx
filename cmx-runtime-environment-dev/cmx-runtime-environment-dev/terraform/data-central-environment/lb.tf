resource "aws_alb" "dundas_alb" {
  name               = "CMXData-${var.environment}-dundas-alb"
  load_balancer_type = "application"
  internal           = true
  subnets = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  security_groups = [aws_security_group.alb_dundas_sg.id]

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "CMXData-${var.environment}-dundas_alb"
      Name = "CodaMetrix Data Central ALB - CMXData-${var.environment}-dundas_alb"
    }
  )
}

resource "aws_alb_target_group" "dundas_alb_target_group" {
  name     = "CMXData-${var.environment}-dundas-alb-target"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.environment_vpc.id

  health_check {
    enabled = true
    protocol = "HTTPS"
    matcher = "200,302"
  }
}

resource "aws_alb_listener" "dundas_alb_listener" {
  load_balancer_arn = aws_alb.dundas_alb.arn
  port              = 443
  certificate_arn = aws_acm_certificate.dundas_alb_certificate.arn
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.dundas_alb_target_group.arn
  }
}

resource "aws_alb_listener" "dundas_http_listener" {
  load_balancer_arn = aws_alb.dundas_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
