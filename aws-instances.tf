/**
 * Uses EC2 Launch Template to define how instances should behave
 * in our infrastructure.
 */
locals {
  instance_bootstrap_script = "${path.module}/aws-instances-bootstrap.sh"
  instance_bootstrap_empty_script = "${path.module}/aws-instances-bootstrap-empty.sh"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter { name   = "owner-alias" values = ["amazon"] }
  filter { name   = "name" values = ["amzn2-ami-hvm-*-x86_64-ebs"] }
  filter { name   = "architecture" values = ["x86_64"] }
}

output "aws_ami_name" {
  value = "${data.aws_ami.amazon-linux-2.name}"
}

data "template_file" "init" {
  template = "${file(local.instance_bootstrap_script)}"
  vars = {
    region = "${var.aws_region}"
    cannonical_name = "${local.cannonical_name}"
    app_name = "${local.app_name}"
    environment = "${local.suffix}"
    custom_script = "${file(var.custom_script == "-" ? local.instance_bootstrap_empty_script : var.custom_script)}"
  }
}

data "aws_ssm_parameter" "ssh_public_key" {
  name = "SSH_PUB_DEPLOYMENT_KEY"
  with_decryption = true
}

resource "aws_key_pair" "ssh_public_key" {
  key_name = "${local.cannonical_name}"
  public_key = "${data.aws_ssm_parameter.ssh_public_key.value}"
}

resource "aws_launch_template" "default" {
  name = "${local.cannonical_name}"
  description = "Managed by Terraform"

  key_name = "${local.cannonical_name}"
  instance_type = "${var.aws_instance_type}"
  user_data = "${base64encode(data.template_file.init.rendered)}"
  image_id = "${data.aws_ami.amazon-linux-2.id}"

  instance_initiated_shutdown_behavior = "terminate"

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs { volume_size = 8 }
  }

  iam_instance_profile { arn = "${aws_iam_instance_profile.default.arn}" }

  vpc_security_group_ids = [ "${aws_security_group.instances.id}" ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.cannonical_name}"
    }
  }
}