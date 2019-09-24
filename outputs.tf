output "kubeconfig_filename" {
  value = module.eks.kubeconfig_filename
}

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

