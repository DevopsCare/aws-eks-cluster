module "elk" {
  source              = "modules/elk"
  aws_region          = "${local.aws_region}"
  root_domain         = "${var.project_prefix}"
  subnet_ids          = ["${module.vpc.private_subnets[0]}"]
  vpc_id              = "${module.vpc.vpc_id}"
  oauth_proxy_address = "${var.keycloak_oauth_proxy_address}"

  ip_whitelist   = ["10.0.0.0/8"]
  instance_count = "2"
  ebs_size       = "35"
}

module "filebeat" {
  source                 = "modules/filebeat"
  elasticsearch_endpoint = "${module.elk.elasticsearch_endpoint}"
}
