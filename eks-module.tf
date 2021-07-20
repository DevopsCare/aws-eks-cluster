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
  kubectl_assume_role_args = split(",", var.kubectl_assume_role != "" ? join(",", ["\"-r\"", "\"${var.kubectl_assume_role}\""]) : "", )
  cluster_name             = "${var.project_prefix}-eks-cluster"

  worker_groups = flatten([
    for group in var.worker_groups : [
      for az, subnet in zipmap(module.vpc.azs, module.vpc.private_subnets):
      merge(group, {
        subnets = [subnet]
        tags = [
          {
            "key"                 = "k8s.io/cluster-autoscaler/enabled"
            "propagate_at_launch" = "false"
            "value"               = "true"
          },
          {
            "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
            "propagate_at_launch" = "false"
            "value"               = "true"
          },
          {
            "key"                 = "k8s.io/cluster-autoscaler/node-template/label/topology.ebs.csi.aws.com/zone"
            "propagate_at_launch" = "false"
            "value"               = az
          },
        ]
      })
  ]])
}

//noinspection MissingModule
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "v15.1.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.19" # https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html
  tags            = local.eks_tags
  enable_irsa     = true

  cluster_create_timeout = "1h"
  cluster_delete_timeout = "1h"

  vpc_id                                         = module.vpc.vpc_id
  subnets                                        = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  cluster_endpoint_private_access                = true
  cluster_endpoint_public_access                 = true
  cluster_create_endpoint_private_access_sg_rule = true
  cluster_endpoint_private_access_cidrs          = ["10.0.0.0/8"]

  worker_additional_security_group_ids = var.enable_bastion ? [
    aws_security_group.whitelist.id,
    aws_security_group.allow_ssh_from_bastion[0].id,
  ] : [aws_security_group.whitelist.id]

  kubeconfig_name                              = "${local.cluster_name}.${local.aws_region}"
  kubeconfig_aws_authenticator_additional_args = local.kubectl_assume_role_args

  map_roles = [for role in var.eks_authorized_roles :
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${role}"
      username = "eks-admin:{{SessionName}}"
      groups   = ["system:masters"]
  }]

  write_kubeconfig   = true
  config_output_path = "${var.config_output_path}/"

  worker_groups_launch_template = local.worker_groups


  workers_group_defaults = {
    asg_desired_capacity = 1
    asg_max_size         = 25
    asg_min_size         = 0
    asg_force_delete     = true
    spot_price           = var.spot_price
    autoscaling_enabled  = true
    key_name             = var.key_name
    enabled_metrics      = ["GroupInServiceInstances", "GroupDesiredCapacity"]
    kubelet_extra_args   = "--fail-swap-on=false --eviction-hard=memory.available<500Mi --system-reserved=memory=1Gi"
    bootstrap_extra_args = "--enable-docker-bridge true"
    pre_userdata         = <<-EOF
      bash <(curl https://gist.githubusercontent.com/rfvermut/4f141cbdfd107d95018731439ffe737d/raw/001cfdbf532d84c7307be4133883202dbcf96e58/add_swap.sh) 2
      echo "$(jq '."default-ulimits".nofile.Hard=65536 | ."default-ulimits".nofile.Soft=65536 | ."default-ulimits".nofile.Name="NOFILE"' /etc/docker/daemon.json)" > /etc/docker/daemon.json
      systemctl restart docker
EOF

  }
}

// Poor man's money saver
resource "aws_autoscaling_schedule" "tgi-friday" {
  for_each = toset(module.eks.workers_asg_names)

  scheduled_action_name  = "friday-off"
  recurrence             = "0 1 * * SAT"
  min_size               = -1
  max_size               = -1
  desired_capacity       = 0
  autoscaling_group_name = each.key
}

resource "aws_autoscaling_schedule" "monday-im-in-love" {
  scheduled_action_name  = "monday-on"
  recurrence             = "0 7 * * MON"
  min_size               = -1
  max_size               = -1
  desired_capacity       = 1
  autoscaling_group_name = module.eks.workers_asg_names[0]
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = module.eks.worker_iam_role_name
}
