resource "aws_iam_policy" "developer_access_policies" {
  for_each    = toset(keys(var.developers))
  name        = "${var.iam_access_policy_prefix}-${each.value}"
  path        = var.iam_resource_path
  description = "Development resource access policy for ${each.value}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.developer_buckets[each.value].arn}",
        "${aws_s3_bucket.developer_buckets[each.value].arn}/*"
      ]
    },
    {
      "Action": [
        "sqs:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_sqs_queue.casebuilder_developer_queues[each.value].arn}",
        "${aws_sqs_queue.caseevents_developer_queues[each.value].arn}",
        "${aws_sqs_queue.activitylog_developer_queues[each.value].arn}",
        "${aws_sqs_queue.munotification_developer_queues[each.value].arn}",
        "${aws_sqs_queue.externaltaskmonitor_developer_queues[each.value].arn}",
        "${aws_sqs_queue.charge_processor_developer_queues[each.value].arn}"
      ]
    },
    {
      "Action": [
        "sqs:CreateQueue",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListQueues",
        "sqs:ListQueueTags"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:sqs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Action": [
        "sns:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sns_topic.developer_topics[each.value].arn}"
    },
    {
      "Action": [
        "sns:CreateTopic",
        "sns:GetTopicAttributes",
        "sns:ListTopics",
        "sns:ListTagsForResource"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_kms_key.developer_sns_topic_kms_key[each.value].arn}",
        "${aws_kms_key.developer_sqs_queue_kms_key[each.value].arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user" "developer_users" {
  for_each  = toset(keys(var.developers))
  name      = var.developers[each.value]
  path      = var.iam_resource_path

  tags = {
    Usage = "CodaMetrix Development"
    Name = var.developers[each.value]
    DeveloperName = each.value
  }
}

resource "aws_iam_policy_attachment" "developer_access_policy_attachments" {
  for_each    = toset(keys(var.developers))
  name        = "${each.value}-policy-attachment"
  users       = [var.developers[each.value]]
  policy_arn  = aws_iam_policy.developer_access_policies[each.value].arn
}

output "iam_users" {
  value = aws_iam_user.developer_users
}
