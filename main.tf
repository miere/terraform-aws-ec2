# Configuring other providers
provider "archive" { version = "~> 1.1" }
provider "external" { version = "~> 1.0" }
provider "template" { version = "~> 2.0" }
provider "null" { version = "~> 2.0" }

# Output variables
output "aws_asg_arn" {
  value = "${aws_autoscaling_group.default.arn}"
}

output "aws_iam_role_arn" {
  value = "${aws_iam_role.default.arn}"
}

output "aws_iam_role_name" {
  value = "${aws_iam_role.default.name}"
}

output "aws_route53_record" {
  value = "${aws_route53_record.default.name}"
}