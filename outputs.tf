output "whitelist_sg_id" {
  value = aws_security_group.whitelist.id
}

output "vpc" {
  value = module.vpc
}

output "cluster_name" {
  value = local.cluster_name
}

output "eks_cluster" {
  value = module.eks
}

output "kubeconfig_filename" {
  value = module.eks.kubeconfig_filename
}

output "kubernetes_host" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "kubernetes_ca_certificate" {
  value = data.aws_eks_cluster.cluster.certificate_authority.0.data
}

output "kubernetes_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}
