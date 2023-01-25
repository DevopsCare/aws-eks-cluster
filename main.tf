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

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "github_ip_ranges" "current" {}

data "aws_route53_zone" "project_fqdn" {
  name = var.project_fqdn
}

locals {
  aws_region = data.aws_region.current.name
  vpc_name   = "${var.project_prefix}-vpc"

  vpc_tags = {
    Environment = "${var.project_prefix}-infra"
  }

  eks_tags = {
    Environment = "${var.project_prefix}-infra"
  }

  route53_tags = {
    Name        = "${var.project_prefix}-dns"
    Environment = "${var.project_prefix}-infra"
  }

  // https://support.atlassian.com/organization-administration/docs/ip-addresses-and-domains-for-atlassian-cloud-products/#AtlassiancloudIPrangesanddomains-OutgoingConnections
  atlassian_outgoing = [
    "13.52.5.96/28",
    "13.236.8.224/28",
    "18.136.214.96/28",
    "18.184.99.224/28",
    "18.234.32.224/28",
    "18.246.31.224/28",
    "52.215.192.224/28",
    "104.192.137.240/28",
    "104.192.138.240/28",
    "104.192.140.240/28",
    "104.192.142.240/28",
    "104.192.143.240/28",
    "185.166.143.240/28",
    "185.166.142.240/28",
  ]
}

