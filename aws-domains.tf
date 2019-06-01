/**
 * Domain related configurations, like DNS and Certificates.
 */

data "aws_route53_zone" "domain" {
  name = "${var.aws_hosted_domain}."
}

data "aws_acm_certificate" "wildcard" {
  domain   = "*.${var.aws_hosted_domain}"
  statuses = ["ISSUED"]
}

resource "aws_route53_record" "default" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "${local.fqdns_domain}"
  type    = "A"

  alias {
    name                   = "${aws_alb.default.dns_name}"
    zone_id                = "${aws_alb.default.zone_id}"
    evaluate_target_health = true
  }
}