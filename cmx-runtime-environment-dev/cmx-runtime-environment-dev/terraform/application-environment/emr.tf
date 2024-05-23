data "template_file" "emr_configuration" {
  template = "${file("${path.module}/templates/emr_configuration.json.tmpl")}"
}

data "template_file" "emr_security_configuration" {
  template = "${file("${path.module}/templates/emr_security_configuration.json.tmpl")}"

  vars = {
    kms_key_id       = aws_kms_key.application_data_lake_emr_kms_key.key_id
    s3_bucket_object = "s3://${aws_s3_bucket.application_configuration_bucket.bucket}/${aws_s3_bucket_object.emr_spark_certs.id}"
  }
}

resource "aws_emr_security_configuration" "emr_security_configuration" {
  name          = "CMXApp-${var.environment}-emr_security_configuration"
  configuration = data.template_file.emr_security_configuration.rendered
}

data "template_file" "emr_autoscaling_policy" {
  template = "${file("${path.module}/templates/emr_autoscaling_policy.json.tmpl")}"

  vars = {
    min_capacity = var.emr_core_instance_count_min
    max_capacity = var.emr_core_instance_count_max
  }
}

resource "aws_emr_cluster" "application_data_warehouse_emr_spark_cluster" {
  name                              = "CMXApp-${var.environment}-application-data-warehouse-emr-spark-cluster"
  release_label                     = var.emr_release_label
  applications                      = ["Spark", "Zeppelin", "Ganglia"]
  log_uri                           = "s3n://${aws_s3_bucket.application_logs_bucket.bucket}/application_data_warehouse_emr/"
  termination_protection            = true
  keep_job_flow_alive_when_no_steps = true
  ebs_root_volume_size              = var.emr_ebs_root_volume_size

  ec2_attributes {
    subnet_id                         = aws_subnet.emr_private_subnet.id
    emr_managed_master_security_group = aws_security_group.application_dw_emr_master_security_group.id
    emr_managed_slave_security_group  = aws_security_group.application_dw_emr_core_security_group.id
    service_access_security_group     = aws_security_group.application_dw_emr_service_access_security_group.id
    instance_profile                  = aws_iam_instance_profile.application_emr_instance_profile.id
    key_name                          = aws_key_pair.emr_host_key_pair.key_name
  }

  master_instance_group {
    name           = var.emr_master_instance_group_name
    instance_type  = var.emr_master_instance_type
    instance_count = 1
  }

  core_instance_group {
    name           = var.emr_core_instance_group_name
    instance_type  = var.emr_core_instance_type
    instance_count = var.emr_core_instance_count_min

    ebs_config {
      size = var.emr_core_volume_size_in_gb
      type = var.emr_core_volume_type
    }

    autoscaling_policy = data.template_file.emr_autoscaling_policy.rendered
  }

  bootstrap_action {
    path = "s3://${data.aws_s3_bucket_object.emr_bootstrap_script.bucket}/${data.aws_s3_bucket_object.emr_bootstrap_script.key}"
    name = var.emr_bootstrap_action_name
  }

  service_role           = aws_iam_role.application_emr_service_role.id
  autoscaling_role       = aws_iam_role.application_emr_autoscaling_role.id
  security_configuration = aws_emr_security_configuration.emr_security_configuration.name
  configurations         = data.template_file.emr_configuration.rendered

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.shared_resource_tags,
    {
      Type = "application_data_warehouse_emr_spark_cluster"
      Name = "CodaMetrix Application EMR - application_data_warehouse_emr_spark_cluster"
    }
  )
}
