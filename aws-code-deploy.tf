# Code Deploy
resource "aws_codedeploy_app" "default" {
  compute_platform = "Server"
  name             = "${local.cannonical_name}"
}

resource "aws_codedeploy_deployment_group" "default" {
  app_name               = "${aws_codedeploy_app.default.name}"

  deployment_config_name = "${var.aws_deployment_config}"
  deployment_group_name  = "${var.aws_deployment_group}"
  service_role_arn       = "${aws_iam_role.default.arn}"

  autoscaling_groups = [ "${aws_autoscaling_group.default.name}" ]

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = "${aws_alb_target_group.default.name}"
    }
  }
}