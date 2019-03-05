module "elk" {
    source = "modules/elk"
    aws_region = "${var.aws_region}"
    domain = "${local.cluster_name}"
    ip_whitelist = ["10.0.0.0/8"]
    subnet_ids = ["${module.vpc.private_subnets[0]}"]
    vpc_id = "${module.vpc.vpc_id}"
}
