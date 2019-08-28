# Load Balancer
resource "aws_alb" "default" {
  name = "${local.cannonical_name}"

  security_groups = [ "${aws_security_group.load_balancer.id}" ]
  load_balancer_type = "application"
  internal = "${var.aws_lb_is_internal}"

  subnets = [ "${var.aws_lb_subnet_ids}" ]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.default.arn}"

  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "${aws_alb_listener.https.port}"
      protocol    = "${aws_alb_listener.https.protocol}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.default.arn}"

  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = "${data.aws_acm_certificate.wildcard.arn}"

  "default_action" {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.default.arn}"
  }
}

/**
 * Blue deployment configuration.
 */
resource "aws_alb_target_group" "default" {
  name = "${local.cannonical_name}"
  port = "${var.aws_instance_web_port}"
  protocol = "${var.aws_instance_web_protocol}"
  vpc_id = "${var.aws_vpc_id}"

  deregistration_delay = "${var.aws_lb_deregistration_delay}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${var.aws_lb_cookie_duration}"
    enabled         = "${var.aws_lb_is_stickiness}"
  }

  health_check {
    path = "${var.aws_lb_health_check_url}"
    interval = 5
    timeout = 4
    healthy_threshold = 3
  }
}

resource "aws_autoscaling_group" "default" {
  name = "${local.cannonical_name}"
  vpc_zone_identifier = ["${var.aws_instances_subnet_ids}"]

  desired_capacity   = "${var.aws_asg_instances_desired}"
  max_size           = "${var.aws_asg_instances_max}"
  min_size           = "${var.aws_asg_instances_min}"

  health_check_type = "${var.aws_lb_health_check_type}"
  health_check_grace_period = "${var.aws_lb_health_check_grace_period}"
  target_group_arns = [ "${aws_alb_target_group.default.arn}" ]

  launch_template {
    id      = "${aws_launch_template.default.id}"
    version = "${aws_launch_template.default.latest_version}"
  }
}