locals {
  worker_asg_count         = 6
  cluster_name             = "${terraform.workspace}-cluster"
  kubectl_assume_role_args = "${split(",", var.kubectl_assume_role != "" ? join(",",list("\"-r\"", "\"${var.kubectl_assume_role}\"")) : "")}"
}

//noinspection MissingModule
module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version      = ">= 2.0"
  cluster_name = "${local.cluster_name}"

  subnets = [
    "${module.vpc.private_subnets}",
  ]

  tags   = "${local.eks_tags}"
  vpc_id = "${module.vpc.vpc_id}"

  worker_additional_security_group_ids = [
    "${aws_security_group.whitelist.id}",
    "${aws_security_group.allow_ssh_from_bastion.id}",
  ]

  kubeconfig_aws_authenticator_additional_args = "${local.kubectl_assume_role_args}"

  map_roles = [
    {
      // TODO needs magic? Needs special named role?
      role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSReservedSSO_SystemAdministrator_b3ce867e2b11b535"
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
      subnets = "${module.vpc.private_subnets[2]}"
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
    {
      instance_type = "t3.xlarge"
      subnets       = "${module.vpc.private_subnets[2]}"
    },
  ]

  /*    {
      subnets = "${module.vpc.private_subnets[3]}"
    },
    {
      subnets = "${module.vpc.private_subnets[4]}"
    },
    {
      subnets = "${module.vpc.private_subnets[5]}"
    },*/

  workers_group_defaults = {
    asg_desired_capacity = 1
    asg_max_size         = 15
    asg_min_size         = 0
    instance_type        = "t3.medium"
    spot_price           = "${var.spot_price}"
    autoscaling_enabled  = 1
    key_name             = "${var.key_name}"

    // SWAP. Ppl say it's bad idea?
    //    pre_userdata         = "bash <(curl https://gist.githubusercontent.com/rfvermut/4f141cbdfd107d95018731439ffe737d/raw/001cfdbf532d84c7307be4133883202dbcf96e58/add_swap.sh) 2"
    //    kubelet_extra_args   = "--fail-swap-on=false --eviction-hard=memory.available<500Mi --system-reserved=memory=1Gi"
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

data "aws_iam_policy_document" "common-s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration",
    ]

    resources = [
      "arn:aws:s3:::${var.org_rev_fqdn}.${var.project_prefix}.common",
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectTagging",
      "s3:GetObjectTagging",
      "s3:DeleteObjectTagging",
    ]

    resources = [
      "arn:aws:s3:::${var.org_rev_fqdn}.${var.project_prefix}.common/*",
    ]
  }
}

resource "aws_iam_role_policy" "common-s3" {
  name   = "common-s3"
  role   = "${module.eks.worker_iam_role_name}"
  policy = "${data.aws_iam_policy_document.common-s3.json}"
}

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
