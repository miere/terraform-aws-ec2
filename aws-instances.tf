/**
 * Uses EC2 Launch Template to define how instances should behave
 * in our infrastructure.
 */
locals {
  instance_bootstrap_script = "${path.module}/aws-instances-bootstrap.sh"
  instance_bootstrap_script_empty = "${path.module}/aws-instances-bootstrap.empty"
  ec2_user_data_file        = var.custom_script == "" ? local.instance_bootstrap_script_empty : var.custom_script
}

output "aws_ami_name" {
  value = data.aws_ami.amazon-linux-2.name
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "template_file" "custom_init" {
  template = file(local.ec2_user_data_file)
  vars = {
    region          = data.aws_region.current.name
    cannonical_name = local.cannonical_name
    app_name        = local.app_name
    environment     = var.environment
    config_prefix   = local.config_prefix
  }
}

data "template_file" "init" {
  template = file(local.instance_bootstrap_script)
  vars = {
    region          = data.aws_region.current.name
    cannonical_name = local.cannonical_name
    app_name        = local.app_name
    environment     = var.environment
    config_prefix   = local.config_prefix
    custom_script   = data.template_file.custom_init.rendered
  }
}

resource "aws_launch_template" "default" {
  name        = local.cannonical_name
  description = "Managed by Terraform"

  instance_type = var.aws_instance_type
  user_data     = base64encode(data.template_file.init.rendered)
  image_id      = data.aws_ami.amazon-linux-2.id

  instance_initiated_shutdown_behavior = "terminate"

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs { volume_size = 8 }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.default.arn
  }

  vpc_security_group_ids = [aws_security_group.instances.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.cannonical_name
    }
  }
}