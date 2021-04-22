/*
* Copyright (c) 2020 Risk Focus Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

locals {
  type_public = {
    "type" = "public"
  }
  type_private = {
    "type" = "private"
  }
}

//noinspection MissingModule
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=2.70.0,~>2"
  cidr    = var.vpc_cidr
  name    = local.vpc_name
  tags = merge(
    local.vpc_tags,
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    },
  )
  public_subnet_tags       = local.type_public
  private_subnet_tags      = local.type_private
  public_route_table_tags  = local.type_public
  private_route_table_tags = local.type_private

  public_subnets = [
    cidrsubnet(cidrsubnet(var.vpc_cidr, 2, 2), 4, 0),
    cidrsubnet(cidrsubnet(var.vpc_cidr, 2, 2), 4, 1),
  ]

  # TODO: use data to get AZS
  azs = [
    "${local.aws_region}a",
    "${local.aws_region}b",
  ]

  private_subnets = [
    cidrsubnet(var.vpc_cidr, 2, 0),
    cidrsubnet(var.vpc_cidr, 2, 1),
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
}

resource "aws_security_group" "whitelist" {
  name        = "${var.project_prefix}-eks-whilelist"
  description = "Set of whitelisted IPs for ${var.project_prefix} + GitHub hooks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.ip_whitelist
  }

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = concat(
        var.whitelist_github_hooks ? data.github_ip_ranges.current.hooks : [],
        var.whitelist_atlassian_outgoing ? local.atlassian_outgoing : [],
      )
    }
  }
}
