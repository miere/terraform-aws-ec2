/**
 * IAM Permissions.
 *
 * Setup all required permission in order to have its artifacts properly
 * deployed the API, insert messages into the SQS queue and even writting
 * into Cloudwatch Logs.
 */

# Instance Profile
resource "aws_iam_instance_profile" "default" {
  name = "${local.cannonical_name}"
  role = "${aws_iam_role.default.name}"
}

# Configures the IAM Role required to perform the Lambda Execution
resource "aws_iam_role" "default" {
  name = "${replace(local.cannonical_name, "-", "_")}"
  assume_role_policy = "${jsonencode(local.iam_role)}"
  description = "Managed by Terraform"
}

# Configure Lambda to write Cloudwatch Logs
resource "aws_iam_policy" "default" {
  name = "${replace(local.cannonical_name, "-", "_")}"
  path = "/"
  description = "Managed by Terraform"
  policy = "${jsonencode(local.iam_policy)}"
}

# Attaching Policy to Role
resource "aws_iam_role_policy_attachment" "default" {
  role = "${aws_iam_role.default.name}"
  policy_arn = "${aws_iam_policy.default.arn}"
}

locals {

  # IAM Role
  iam_role = {
    "Version" = "2012-10-17",
    "Statement" = [{
      "Effect" = "Allow",
      "Principal" = {
        "Service" = [
          "ec2.amazonaws.com",
          "application-autoscaling.amazonaws.com",
          "codedeploy.amazonaws.com"
        ]
      },
      "Action" = "sts:AssumeRole"
    }]
  }

  # IAM Policy
  iam_policy = {
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" = "Allow",
        "Action" = [
          "ec2:DescribeTags",
          "logs:*",
          "cloudwatch:PutMetric*",
          "ssm:DescribeParameters",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:UpdateInstanceInformation"
        ],
        "Resource" = "*"
      },
      {
        "Effect" = "Allow",
        "Action" = [
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:DeleteLifecycleHook",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLifecycleHooks",
          "autoscaling:PutLifecycleHook",
          "autoscaling:RecordLifecycleActionHeartbeat",
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:EnableMetricsCollection",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribePolicies",
          "autoscaling:DescribeScheduledActions",
          "autoscaling:DescribeNotificationConfigurations",
          "autoscaling:DescribeLifecycleHooks",
          "autoscaling:SuspendProcesses",
          "autoscaling:ResumeProcesses",
          "autoscaling:AttachLoadBalancers",
          "autoscaling:PutScalingPolicy",
          "autoscaling:PutScheduledUpdateGroupAction",
          "autoscaling:PutNotificationConfiguration",
          "autoscaling:PutLifecycleHook",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DeleteAutoScalingGroup",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:TerminateInstances",
          "tag:GetTags",
          "tag:GetResources",
          "sns:Publish",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:PutMetricAlarm",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeInstanceHealth",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "s3:GetObject"
        ],
        "Resource" = "*"
      }
    ]
  }
}