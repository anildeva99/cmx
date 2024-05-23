resource "aws_cloudwatch_log_group" "application_vpc_flow_log_group" {
  name = var.app_vpc_flow_log_group_name
  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_vpc_flow_log_group"
      Name = "CodaMetrix Inspector - application_vpc_flow_log_group"
    }
  )
}

resource "aws_flow_log" "application_vpc_flow_log" {
  log_destination = aws_cloudwatch_log_group.application_vpc_flow_log_group.arn
  iam_role_arn    = aws_iam_role.vpc_flow_log_service_role.arn
  vpc_id          = aws_vpc.application_vpc.id
  traffic_type    = var.app_vpc_flow_log_traffic_type
}

resource "aws_cloudwatch_log_group" "ingress_vpc_flow_log_group" {
  name = var.ingress_vpc_flow_log_group_name
  tags = merge(
    var.shared_resource_tags,
    {
      Type = "ingress_vpc_flow_log_group"
      Name = "CodaMetrix Inspector - ingress_vpc_flow_log_group"
    }
  )
}

resource "aws_flow_log" "ingress_vpc_flow_log" {
  log_destination = aws_cloudwatch_log_group.ingress_vpc_flow_log_group.arn
  iam_role_arn    = aws_iam_role.vpc_flow_log_service_role.arn
  vpc_id          = aws_vpc.ingress_vpc.id
  traffic_type    = var.ingress_vpc_flow_log_traffic_type
}
