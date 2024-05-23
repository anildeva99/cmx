
resource "aws_ecr_repository_policy" "ecr_cross_account_repository_policy" {
  repository = element(var.ecr_repos, count.index)
  count      = length(var.ecr_repos)

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECR Cross Account Respository Policy ${element(var.ecr_repos, count.index)}",
            "Effect": "Allow",
            "Principal": {
              "AWS": [
                ${join(",", data.template_file.foreign_account_root_template.*.rendered)}
              ]
            },
            "Action": [
              "ecr:BatchCheckLayerAvailability",
              "ecr:BatchGetImage",
              "ecr:GetDownloadUrlForLayer",
              "ecr:DescribeImages"
            ]
        }
    ]
}
EOF
}
