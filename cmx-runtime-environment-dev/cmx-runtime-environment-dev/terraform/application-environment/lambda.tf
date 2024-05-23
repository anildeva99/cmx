data "archive_file" "cloudwatch_log_groups_to_es_archive" {
  type        = "zip"
  source_dir  = "${path.module}/${var.firehose_lambda_function_dir}"
  output_path = "${path.module}/files/kinesis-firehose-cloudwatch-logs-processor.zip"
}

# Create the lambda function
# The lambda function to transform data from compressed format in Cloudwatch
# to something Elasticsearch can handle (uncompressed)
resource "aws_lambda_function" "cloudwatch_log_groups_to_es" {
  # name can not be longer than 64 characters, so make it shorter
  function_name    = "CMXApplication-${var.environment}-cloudwatch_log_groups_to_es"
  description      = "Transform data from CloudWatch format to Elastic Search compatible format"
  filename         = data.archive_file.cloudwatch_log_groups_to_es_archive.output_path
  role             = aws_iam_role.cloud_watch_ingest_to_es_role.arn
  handler          = "kinesis-firehose-cloudwatch-logs-processor.handler"
  source_code_hash = data.archive_file.cloudwatch_log_groups_to_es_archive.output_base64sha256
  runtime          = var.firehose_lambda_runtime_type
  timeout          = var.firehose_lambda_function_timeout

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "cloudwatch_log_groups_to_es"
      Name = "CodaMetrix Application Lambda - cloudwatch_log_groups_to_es"
    }
  )
}

resource "null_resource" "rotate_elasticseach_indices_pkg_install_python_dependencies" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/create_elasticsearch_rotation_lambda_python_pkg.sh"

    environment = {
      source_code_path = var.elasticsearch_index_rotation_lambda.pkg_path_source_code
      function_name    = var.elasticsearch_index_rotation_lambda.pkg_function_name
      path_module      = path.module
      runtime          = var.elasticsearch_index_rotation_lambda.pkg_runtime
      path_cwd         = path.cwd
    }
  }
}

data "archive_file" "elasticsearch_rotate_indices_archive" {
  depends_on  = [null_resource.rotate_elasticseach_indices_pkg_install_python_dependencies]
  type        = "zip"
  source_dir  = "${path.module}/${var.elasticsearch_index_rotation_lambda.lambda_function_dir}"
  output_path = "${path.module}/files/rotate-elasticsearch-index-lambda.zip"
}

resource "aws_lambda_function" "elasticsearch_rotate_indices" {
  # function name cannot be longer than 64 characters
  for_each      = var.elasticsearch_index_rotation
  function_name = "CMXApp-${var.environment}-${each.key}-elasticsearch_rotate_indices"
  description   = "Rotate indices of ${each.key} Elasticsearch of ${var.environment}"
  handler       = "rotate-elasticsearch-index-lambda.lambda_handler"
  runtime       = var.elasticsearch_index_rotation_lambda.pkg_runtime

  role        = aws_iam_role.elasticsearch_rotate_index_role.arn
  memory_size = var.elasticsearch_index_rotation_lambda.memory_size
  timeout     = var.elasticsearch_index_rotation_lambda.timeout

  depends_on = [
    null_resource.rotate_elasticseach_indices_pkg_install_python_dependencies,
    data.archive_file.elasticsearch_rotate_indices_archive,
  ]
  source_code_hash = data.archive_file.elasticsearch_rotate_indices_archive.output_base64sha256
  filename         = data.archive_file.elasticsearch_rotate_indices_archive.output_path

  vpc_config {
    subnet_ids         = [local.network_subnets_for_es_rotation_lambda[each.key]]
    security_group_ids = [aws_security_group.rotate_elasticsearch_index_lambda_function_sg[each.key].id]
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "${var.environment}-${each.key}-elasticsearch_backup_snapshots_and_rotate_indices"
      Name = "CodaMetrix Application Lambda - ${var.environment}-${each.key}-elasticsearch_rotate_indices"
    }
  )
}
