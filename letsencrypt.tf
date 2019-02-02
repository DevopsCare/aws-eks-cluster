module "cert-manager" {
  source     = "modules/cert-manager"
  aws_region = "${var.aws_region}"
  email      = "${var.email}"
  kubeconfig = "${path.root}/kubeconfig_${local.cluster_name}"
}
