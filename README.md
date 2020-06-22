# Terraform EC2 HA
Zero Downtime and Highly Available deployment infrastructure using Terraform and EC2.

## Basic Usage
```terraform
/* -----------------------------------------------------------
 *  Configure Gambit High Available Infrastructure
 * ----------------------------------------------------------- */
module "aws-ec2-ha" {
  source  = "miere/ec2/aws"
  version = "2.0.0" # Use 1.0.0 for terraform 0.11 or earlier

  aws_vpc_id                  = "..."
  aws_instances_subnet_ids    = "..."

  aws_lb_subnet_ids    = "..."
  aws_lb_health_check_url  = "/health"
  aws_lb_health_check_type = "ELB"
  aws_lb_health_check_grace_period = "60"

  aws_hosted_domain = "example.com"
  dns_entry         = "api"
  environment       = "production"
}
```

## Takeaways from this module
1. This module was developed to deploy applications using CodeDeploy as orchestration mechanism.
1. Applications will be running on EC2 behind an Application Load Balancer.
1. An Auto Scaling Group will be created to ensure the application stays up and reliable.
1. Several other resources will be created automatically for each configured module.
1. Internal resources will be named using this convention as a prefix name: `{appname}-{environment}-`. For example, using the sample configuration above, the security group created for the instances will be named `api-production-instances`.
1. Most of the created resources is exposed as output attribute which you can use as reference on your terraform script.

## Reporting Bugs/Feature Requests
We welcome you to use the GitHub issue tracker to report bugs or suggest features.

When filing an issue, please check existing open, or recently closed, issues to make sure somebody else hasn't already
reported the issue. Please try to include as much information as you can. Details like these are incredibly useful:

* A reproducible test case or series of steps
* The version of our code being used
* Any modifications you've made relevant to the bug
* Anything unusual about your environment or deployment


## Contributing via Pull Requests
Contributions via pull requests are much appreciated. Before sending us a pull request, please ensure that:

1. You are working against the latest source on the *master* branch.
2. You check existing open, and recently merged, pull requests to make sure someone else hasn't addressed the problem already.
3. You open an issue to discuss any significant work - we would hate for your time to be wasted.

To send us a pull request, please:

1. Fork the repository.
2. Modify the source; please focus on the specific change you are contributing. If you also reformat all the code, it will be hard for us to focus on your change.
3. Ensure local tests pass.
4. Commit to your fork using clear commit messages.
5. Send us a pull request, answering any default questions in the pull request interface.
6. Pay attention to any automated CI failures reported in the pull request, and stay involved in the conversation.

GitHub provides additional document on [forking a repository](https://help.github.com/articles/fork-a-repo/) and
[creating a pull request](https://help.github.com/articles/creating-a-pull-request/).


## Finding contributions to work on
Looking at the existing issues is a great way to find something to contribute on. As our projects, by default, use the default GitHub issue labels ((enhancement/bug/duplicate/help wanted/invalid/question/wontfix), looking at any 'help wanted' issues is a great place to start.

## License
This is release under the Apache License 2 terms.
