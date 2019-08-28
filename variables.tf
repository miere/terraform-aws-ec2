# Local Custom Variables
locals {
  fqdns_domain = "${var.dns_entry}.${var.aws_hosted_domain}"
  app_name = "${var.name != "" ? var.name : var.dns_entry}"
  suffix = "${var.environment != "" ? var.environment : var.aws_region}"
  cannonical_name = "${join("-", list(local.app_name, local.suffix))}",
  config_prefix = "${var.config_prefix != "" ? var.config_prefix : local.app_name}"
}

# Input Variables
variable "aws_region" {
  description = "AWS region in which the artifact will be deployed to. It will be used by S3 and Code Deploy."
}

variable "aws_instance_type" {
  description = "AWS EC2 instance type that will be used to spin up the service. Default: t3.nano"
  default = "t3.nano"
}

variable "aws_instances_subnet_ids" {
  description = "AWS Subnet IDs in which your instances will be placed on."
  type = "list"
}

variable "aws_instance_web_port" {
  description = "Define which port should be mapped from the ALB to target instance."
  default = "8080"
}

variable "aws_instance_web_protocol" {
  description = "Define which protocol should be mapped from the ALB to target instance."
  default = "HTTP"
}

variable "aws_hosted_domain" {
  description = "AWS Route 53 hosted zone domain. e.g. my.domain.com"
}

variable "aws_vpc_id" {
  description = "AWS VPC ID in which your services will be deployed to."
}

variable "aws_deployment_config" {
  description = "AWS CodeDeploy deployment config. Default: CodeDeployDefault.OneAtATime"
  default = "CodeDeployDefault.OneAtATime"
}

variable "aws_deployment_group" {
  description = "AWS CodeDeploy deployment group. Default: default"
  default = "default"
}

variable "aws_lb_health_check_type" {
  description = "Define how AWS should check if instances are healthy or not."
  default = "ELB"
}

variable "aws_lb_subnet_ids" {
  description = "AWS Subnet IDs in which your load balancer will be placed on."
  type = "list"
}

variable "aws_lb_health_check_url" {
  description = "Define which URL ALB should probe to ensure the instances are healthy."
  default = "/health-check"
}

variable "aws_lb_health_check_grace_period" {
  description = "Grace period before the instance being checked."
  default = "30"
}

variable "aws_lb_deregistration_delay" {
  description = "The delay expected during the draining phase to leverage a graceful shutdown for deregistered machines"
  default = "60"
}

variable "aws_lb_is_internal" {
  description = "Defines whether the ALB is internal or not. Default: false"
  default = false
}

variable "aws_lb_is_stickiness" {
  description = "Defines ALB should be routed to the same target"
  default = false
}

variable "aws_lb_cookie_duration" {
  description = "The time period in seconds"
  default = 60
}


variable "aws_asg_instances_desired" {
  description = "Desired number of instances on the ASG."
  default = "2"
}

variable "aws_asg_instances_min" {
  description = "Minimum number of instances on the ASG."
  default = "2"
}

variable "aws_asg_instances_max" {
  description = "Maximum number of instances on the ASG."
  default = "3"
}

variable "ssh_public_key_ssm_name" {
  description = "The SSM Parameter name containing the SSH public key to log into the EC2 instances. Optional."
  default = ""
}

variable "dns_entry" {
  description = "The Register A DNS entry that will be created for your service. It will be used as suffix for your 'aws_hosted_domain'"
}

variable "name" {
  description = "Optional name that will be used as suffix for every AWS resource created by this script."
  default = ""
}

variable "config_prefix" {
  description = "Optional prefix used for every SSM Parameter Store that will be retrieved as env var for your app."
  default = ""
}

variable "custom_script" {
  description = "The custom script path. This script, if defined, will be run every time an instance is spin up."
  default = ""
}

variable "environment" {
  description = "An environment deployment identifier."
  default = ""
}
