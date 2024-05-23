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

resource "random_id" "id" {
	  byte_length = 4
}
