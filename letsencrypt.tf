module "cert-manager" {
  source     = "./modules/cert-manager"
  aws_region = local.aws_region
  email      = var.letsencrypt-email
  kubeconfig = module.eks.kubeconfig_filename
}

