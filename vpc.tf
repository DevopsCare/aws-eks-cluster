//noinspection MissingModule
module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  version        = ">=1.46.0"
  cidr           = "172.31.224.0/20"
  tags           = "${merge(local.vpc_tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))}"
  public_subnets = ["172.31.230.0/24", "172.31.231.0/24"]

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c",
  ]

  /*
    "${data.aws_region.current.name}d",
    "${data.aws_region.current.name}e",
    "${data.aws_region.current.name}f",
*/

  private_subnets = [
    "172.31.224.0/24",
    "172.31.225.0/24",
    "172.31.226.0/24",
  ]

  /*
    "172.31.227.0/24",
    "172.31.228.0/24",
    "172.31.229.0/24",
*/

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
