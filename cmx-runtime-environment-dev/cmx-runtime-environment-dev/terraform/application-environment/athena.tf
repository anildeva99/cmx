resource "aws_athena_workgroup" "athena_data_lake_workgroup" {
  name = "CMXApp-${var.environment}-athena_data_lake_workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.application_data_lake_athena_output_bucket.bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.athena_output_kms_key.arn
      }
    }
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "athena_data_lake_workgroup"
      Name = "CodaMetrix Application Data Warehouse - athena_data_lake_workgroup"
    }
  )
}
