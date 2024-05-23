resource "aws_cloudwatch_log_group" "environment_vpc_flow_log_group" {
  name = var.env_vpc_flow_log_group_name
  tags = merge(
    var.shared_resource_tags,
    {
      Type = "environment_vpc_flow_log_group"
      Name = "CodaMetrix Data Central Inspector - environment_vpc_flow_log_group"
    }
  )
}

resource "aws_flow_log" "environment_vpc_flow_log" {
  log_destination = aws_cloudwatch_log_group.environment_vpc_flow_log_group.arn
  iam_role_arn    = aws_iam_role.vpc_flow_log_service_role.arn
  vpc_id          = aws_vpc.environment_vpc.id
  traffic_type    = var.env_vpc_flow_log_traffic_type
}
