provider "kubernetes" {
  config_path = "${path.root}/kubeconfig_${local.cluster_name}"
}

provider "helm" {
  service_account = "eks-admin"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"

  kubernetes = {
    config_path = "${path.root}/kubeconfig_${local.cluster_name}"
  }
}

provider "aws" {
  version = ">= 1.47.0"
  region  = "${var.aws_region}"
}

data "aws_caller_identity" "current" {}

locals {
  vpc_tags = {
    Name        = "${var.project_prefix}-vpc"
    Environment = "${var.project_prefix}-infra"
  }

  eks_tags = {
    Name        = "${var.project_prefix}-eks"
    Environment = "${var.project_prefix}-infra"
  }

  route53_tags = {
    Name        = "${var.project_prefix}-dns"
    Environment = "${var.project_prefix}-infra"
  }

  bastion_tags = {
    Name        = "${var.project_prefix}-eks-bastion"
    Environment = "${var.project_prefix}-infra"
  }

  // TODO update from API
  github_meta_hooks = [
    "192.30.252.0/22",
    "185.199.108.0/22",
    "140.82.112.0/20",
  ]
}
