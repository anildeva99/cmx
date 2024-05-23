data "template_file" "worker_node_init_script" {
  template = file("scripts/worker_node_init.cfg")
  vars = {
    Region = var.aws_region
  }
}

data "template_file" "application_worker_node_userdata_shell_script" {
  template = file("scripts/worker_node_user_data.sh")
  vars = {
    ClusterName        = var.cluster_name
    BootstrapArguments = var.node_bootstrap_args
  }
}

data "template_file" "bastion_host_init_script" {
  template = file("scripts/bastion_host_init.cfg")
  vars = {
    Region = var.aws_region
  }
}

data "template_file" "bastion_host_userdata_shell_script" {
  template = file("scripts/bastion_host_user_data.sh")
  vars = {
  }
}

data "template_file" "mirth_instance_init_script" {
  template = file("scripts/mirth_init.cfg")
  vars = {
    Region = var.aws_region
  }
}

data "template_file" "mirth_instance_userdata_shell_script" {
  template = file("scripts/mirth_user_data.sh")
  vars = {
  }
}

data "template_cloudinit_config" "application_worker_node_cloudinit" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.worker_node_init_script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.application_worker_node_userdata_shell_script.rendered
  }
}

data "template_cloudinit_config" "bastion_host_cloudinit" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.bastion_host_init_script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.bastion_host_userdata_shell_script.rendered
  }
}

data "template_cloudinit_config" "mirth_instance_cloudinit" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.mirth_instance_init_script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.mirth_instance_userdata_shell_script.rendered
  }
}

resource "aws_s3_bucket_object" "emr_bootstrap_script_obj" {
  key    = "emr_bootstrap_script.sh"
  bucket = aws_s3_bucket.application_configuration_bucket.bucket
  source = var.emr_bootstrap_script_file_path
}

data "aws_s3_bucket_object" "emr_bootstrap_script" {
  depends_on = [aws_s3_bucket_object.emr_bootstrap_script_obj]
  bucket     = aws_s3_bucket.application_configuration_bucket.bucket
  key        = "emr_bootstrap_script.sh"
}

resource "random_id" "id" {
  byte_length = 4
}

# Random string used for Kinesis related names
resource "random_string" "upper_case_string" {
  for_each = var.cloud_watch_ingest_to_elasticsearch_log_groups
  length   = 8
  upper    = true
  lower    = false
  number   = false
  special  = false
}
