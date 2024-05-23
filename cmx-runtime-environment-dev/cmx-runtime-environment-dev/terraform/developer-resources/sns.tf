resource "aws_sns_topic" "developer_topics" {
  for_each          = toset(keys(var.developers))
  name              = "${var.sns_topic_prefix}-${each.value}"
  kms_master_key_id = aws_kms_key.developer_sns_topic_kms_key[each.value].arn

  tags = {
    Usage         = "CodaMetrix Development"
    Name          = "${var.sns_topic_prefix}-${each.value}"
    DeveloperName = each.value
  }
}

output "sns_topics" {
  value = aws_sns_topic.developer_topics
}
