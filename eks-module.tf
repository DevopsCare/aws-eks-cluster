locals {
  worker_asg_count         = 4
  kubectl_assume_role_args = "${split(",", var.kubectl_assume_role != "" ? join(",",list("\"-r\"", "\"${var.kubectl_assume_role}\"")) : "")}"
  cluster_name             = "${var.eks_cluster_name == "" ? "${var.project_prefix}-eks-cluster" : var.eks_cluster_name}"
}

//noinspection MissingModule
module "eks" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v4.0.2"

#  version         = ">=2.3.1"
  cluster_name    = "${local.cluster_name}"
  cluster_version = "1.12"
  tags            = "${local.eks_tags}"

  //  local_exec_interpreter = ["c:/Program Files/Git/bin/git-sh.exe", "-c"]
  //  manage_aws_auth = false

  vpc_id                               = "${module.vpc.vpc_id}"
  subnets                              = ["${module.vpc.private_subnets[0]}", "${module.vpc.private_subnets[1]}"]
  cluster_endpoint_public_access       = "true"
  cluster_endpoint_private_access      = "true"
  worker_additional_security_group_ids = [
    "${aws_security_group.whitelist.id}",
    "${aws_security_group.allow_ssh_from_bastion.id}",
  ]

  kubeconfig_aws_authenticator_additional_args = "${local.kubectl_assume_role_args}"

  map_roles_count = 3
  map_roles       = [
    {
      role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSReservedSSO_AdministratorAccess_fdd93031f4fbd3aa"
      username = "eks-admin:{{SessionName}}"
      group    = "system:masters"
    },
    {
      // TODO needs magic? Needs special named role?
      role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSReservedSSO_SystemAdministrator_fdd93031f4fbd3aa"
      username = "eks-admin:{{SessionName}}"
      group    = "system:masters"
    },
    {
      role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSReservedSSO_PowerUserAccess_6aa8e8dbe8829cce"
      username = "eks-admin:{{SessionName}}"
      group    = "system:masters"
    },
  ]

  config_output_path = "${var.config_output_path}/"
  worker_group_count = "${local.worker_asg_count}"
  worker_groups      = [
    {
      subnets = "${module.vpc.private_subnets[0]}"
    },
    {
      subnets = "${module.vpc.private_subnets[1]}"
    },
    {
      // Bigger instances
      instance_type = "t3.2xlarge"
      subnets       = "${module.vpc.private_subnets[0]}"
    },
    {
      instance_type = "t3.2xlarge"
      subnets       = "${module.vpc.private_subnets[1]}"
    },
  ]

  workers_group_defaults = {
    asg_desired_capacity = 1
    asg_max_size         = 25
    asg_min_size         = 0
    asg_force_delete     = true
    instance_type        = "t3.large"
    spot_price           = "${var.spot_price}"
    autoscaling_enabled  = 1
    key_name             = "${var.key_name}"
    enabled_metrics      = "GroupInServiceInstances,GroupDesiredCapacity"
    kubelet_extra_args   = "--fail-swap-on=false --eviction-hard=memory.available<500Mi --system-reserved=memory=1Gi"
    bootstrap_extra_args = "--enable-docker-bridge true"

    pre_userdata = <<-EOF
      bash <(curl https://gist.githubusercontent.com/rfvermut/4f141cbdfd107d95018731439ffe737d/raw/001cfdbf532d84c7307be4133883202dbcf96e58/add_swap.sh) 2
      echo "$(jq '."default-ulimits".nofile.Hard=65536 | ."default-ulimits".nofile.Soft=65536 | ."default-ulimits".nofile.Name="NOFILE"' /etc/docker/daemon.json)" > /etc/docker/daemon.json
      systemctl restart docker
      EOF
  }
}

resource "null_resource" "refresh_helm_cache" {
  provisioner "local-exec" {
    command = "helm repo update"
  }
}

// Poor man's money saver
resource "aws_autoscaling_schedule" "tgi-friday" {
  count = "${local.worker_asg_count}"

  scheduled_action_name  = "friday-off"
  recurrence             = "0 1 * * SAT"
  min_size               = -1
  max_size               = -1
  desired_capacity       = 0
  autoscaling_group_name = "${element(module.eks.workers_asg_names, count.index)}"
}

resource "aws_autoscaling_schedule" "monday-im-in-love" {
  scheduled_action_name  = "monday-on"
  recurrence             = "0 7 * * MON"
  min_size               = -1
  max_size               = -1
  desired_capacity       = 1
  autoscaling_group_name = "${module.eks.workers_asg_names[0]}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = "${module.eks.worker_iam_role_name}"
}

// TODO maybe more restrictive
resource "aws_iam_role_policy_attachment" "workers_AmazonRoute53FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  role       = "${module.eks.worker_iam_role_name}"
}

resource "aws_iam_role_policy_attachment" "workers_extra_policy" {
  policy_arn = "${var.extra_policy_arn}"
  role       = "${module.eks.worker_iam_role_name}"
}

# TODO: use these policies instead of full Route53 access
#
# data "aws_iam_policy_document" "cert-manager-route53" {
#   statement {
#     actions = [
#       "route53:GetChange"
#     ]

#     resources = [
#       "arn:aws:route53:::change/${aws_route53_zone.primary.zone_id}",
#     ]
#   }

#   statement {
#     actions = [
#       "route53:ChangeResourceRecordSets"
#     ]

#     resources = [
#       "arn:aws:route53:::hostedzone/${aws_route53_zone.primary.zone_id}",
#     ]
#   }

#   statement {
#     actions = [
#       "route53:ListHostedZonesByName",
#     ]

#     resources = [
#       "*",
#     ]
#   }
# }

# resource "aws_iam_role_policy" "cert-manager-route53" {
#   name   = "cert-manager-route53"
#   role   = "${module.eks.worker_iam_role_name}"
#   policy = "${data.aws_iam_policy_document.cert-manager-route53.json}"
# }

data "aws_iam_policy_document" "eks-default-role" {
  statement {
    actions = ["sts:AssumeRole"]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EKS-Role-*",
    ]
  }
}

resource "aws_iam_role_policy" "eks-default-role" {
  name   = "eks-default-role"
  role   = "${module.eks.worker_iam_role_name}"
  policy = "${data.aws_iam_policy_document.eks-default-role.json}"
}
