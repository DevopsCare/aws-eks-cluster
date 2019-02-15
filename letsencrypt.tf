module "cert-manager" {
  source     = "modules/cert-manager"
  aws_region = "${var.aws_region}"
  email      = "${var.email}"
  kubeconfig = "${var.config_output_path}/kubeconfig_${local.cluster_name}"
}
