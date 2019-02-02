//noinspection MissingModule
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=1.46.0"
  cidr    = "${var.vpc_cidr}"
  tags    = "${merge(local.vpc_tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))}"

  public_subnets = [
    "${cidrsubnet( cidrsubnet(var.vpc_cidr, 2, 2), 4, 0)}",
    "${cidrsubnet( cidrsubnet(var.vpc_cidr, 2, 2), 4, 1)}",
  ]

  # TODO: use data to get AZS
  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
  ]

  private_subnets = [
    "${cidrsubnet(var.vpc_cidr, 2, 0)}",
    "${cidrsubnet(var.vpc_cidr, 2, 1)}",
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
}

resource "aws_security_group" "whitelist" {
  name        = "${var.project_prefix}-${local.cluster_name}-whilelist"
  description = "Set of whitelisted IPs for ${var.project_prefix} + GitHub hooks"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = "${var.ip_whitelist}"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${local.github_meta_hooks}"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${local.github_meta_hooks}"
  }
}
