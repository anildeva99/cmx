resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name = var.vpc_flow_log_group_name
  tags = merge(
    var.shared_resource_tags,
    {
      Type = "vpc_flow_log_group"
      Name = "CodaMetrix Traffic Cop CloudWatch - vpc_flow_log_group"
    }
  )
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  iam_role_arn    = aws_iam_role.vpc_flow_log_service_role.arn
  vpc_id          = aws_vpc.vpc.id
  traffic_type    = var.vpc_flow_log_traffic_type
}
