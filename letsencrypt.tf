module "cert-manager" {
  source     = "modules/cert-manager"
  aws_region = "${local.aws_region}"
  email      = "${var.letsencrypt-email}"
  kubeconfig = "${var.config_output_path}/kubeconfig_${var.project_prefix}-eks-cluster"
}
