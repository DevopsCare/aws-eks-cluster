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
  cluster_name = "${var.project_prefix}-eks-cluster"

  worker_groups = flatten([
    for group in var.worker_groups : [
      for subnet in data.aws_subnet.subnets :
      merge(group, {
        subnet_ids = [subnet.id]

        name                        = "${local.cluster_name}_${subnet.availability_zone}"
        launch_template_description = "Self managed node group ${local.cluster_name} ${subnet.id} ${subnet.availability_zone}"

        # enable discovery of autoscaling groups by cluster-autoscaler
        autoscaling_group_tags = {
          "k8s.io/cluster-autoscaler/enabled" : true,
          "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned",
          "k8s.io/cluster-autoscaler/node-template/label/topology.ebs.csi.aws.com/zone" : subnet.availability_zone,
          "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/zone" : subnet.availability_zone,
          "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/region" : data.aws_region.current.name
        }

      })
  ]])
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v19.4.2"

  cluster_name                    = local.cluster_name
  cluster_version                 = "1.24" # https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      service_account_role_arn = module.vpc_cni_ipv4_irsa_role.iam_role_arn
    }
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  # Self managed node groups will not automatically create the aws-auth configmap so we need to
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    admin_access = {
      description = "Admin ingress to Kubernetes API"
      cidr_blocks = ["10.0.0.0/8"]
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
    }
  }

  tags        = local.eks_tags
  enable_irsa = true

  # START Backwards compatibility with v17
  prefix_separator                   = ""
  iam_role_name                      = local.cluster_name
  cluster_security_group_name        = local.cluster_name
  cluster_security_group_description = "EKS cluster security group."
  # END Backwards compatibility with v17

  cluster_timeouts = {
    create = "1h"
    delete = "1h"
  }

  aws_auth_roles = [for role in var.eks_authorized_roles :
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${role}"
      username = "eks-admin:{{SessionName}}"
      groups   = ["system:masters"]
  }]

  self_managed_node_groups = local.worker_groups
  self_managed_node_group_defaults = {
    desired_size = 1
    max_size     = 25
    min_size     = 0
    force_delete = true

    schedules = {
      friday-off = {
        recurrence       = "0 1 * * SAT"
        desired_capacity = 0
    } }

    launch_template_name            = local.cluster_name
    launch_template_use_name_prefix = true

    vpc_security_group_ids = compact([aws_security_group.whitelist.id, module.ec2_bastion.security_group_id])

    iam_role_additional_policies = {
      AmazonEC2ContainerRegistryPowerUser = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

    # ? TODO
    spot_price      = var.spot_price
    key_name        = var.key_name
    enabled_metrics = ["GroupInServiceInstances", "GroupDesiredCapacity"]

    create_iam_role      = true
    kubelet_extra_args   = "--fail-swap-on=false --eviction-hard=memory.available<500Mi --system-reserved=memory=1Gi"
    bootstrap_extra_args = "--container-runtime containerd"
    pre_userdata         = <<-EOF
      bash <(curl https://gist.githubusercontent.com/rfvermut/4f141cbdfd107d95018731439ffe737d/raw/001cfdbf532d84c7307be4133883202dbcf96e58/add_swap.sh) 2
EOF

  }
}

// Bootstrap cluster that's stop every Friday from a single node
resource "aws_autoscaling_schedule" "monday-on" {
  scheduled_action_name  = "monday-on"
  recurrence             = "0 7 * * MON"
  min_size               = -1
  max_size               = -1
  desired_capacity       = 1
  autoscaling_group_name = module.eks.self_managed_node_groups_autoscaling_group_names[0]
}
