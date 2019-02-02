locals {
  worker_asg_count         = 4
  cluster_name             = "${terraform.workspace}-cluster"
  kubectl_assume_role_args = "${split(",", var.kubectl_assume_role != "" ? join(",",list("\"-r\"", "\"${var.kubectl_assume_role}\"")) : "")}"
}

//noinspection MissingModule
module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version      = ">= 2.1"
  cluster_name = "${local.cluster_name}"

  subnets = [
    "${module.vpc.private_subnets[0]}",
    "${module.vpc.private_subnets[1]}",
  ]

  tags   = "${local.eks_tags}"
  vpc_id = "${module.vpc.vpc_id}"

  worker_additional_security_group_ids = [
    "${aws_security_group.whitelist.id}",
    "${aws_security_group.allow_ssh_from_bastion.id}",
  ]

  kubeconfig_aws_authenticator_additional_args = "${local.kubectl_assume_role_args}"

  map_roles_count = 3

  map_roles = [
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

  kubeconfig_aws_authenticator_env_variables = {
    AWS_PROFILE = "${var.aws_profile}"
  }

  config_output_path = "${var.config_output_path}"
  worker_group_count = "${local.worker_asg_count}"

  worker_groups = [
    {
      subnets = "${module.vpc.private_subnets[0]}"
    },
    {
      subnets = "${module.vpc.private_subnets[1]}"
    },
    {
      // Bigger instances
      instance_type = "t3.xlarge"
      subnets       = "${module.vpc.private_subnets[0]}"
    },
    {
      instance_type = "t3.xlarge"
      subnets       = "${module.vpc.private_subnets[1]}"
    },
  ]

  workers_group_defaults = {
    asg_desired_capacity = 1
    asg_max_size         = 25
    asg_min_size         = 0
    instance_type        = "t3.medium"
    spot_price           = "${var.spot_price}"
    autoscaling_enabled  = 1
    key_name             = "${var.key_name}"
    enabled_metrics      = "GroupInServiceInstances,GroupDesiredCapacity"
  }
}

// Poor man's money saver
resource "aws_autoscaling_schedule" "tgi-friday" {
  count = "${local.worker_asg_count}"

  scheduled_action_name  = "friday-off"
  recurrence             = "0 23 * * FRI"
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

data "aws_iam_policy_document" "eks-assume-role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EKS-Role-*",
    ]
  }
}

resource "aws_iam_role_policy" "eks-assume-role" {
  name   = "eks-assume-role"
  role   = "${module.eks.worker_iam_role_name}"
  policy = "${data.aws_iam_policy_document.eks-assume-role.json}"
}
