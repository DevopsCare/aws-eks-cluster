
/*
*Copyright (c) 2020 Risk Focus Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


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

output "cad3_superuser" {
  value = var.cad3_superuser ? aws_iam_role.cad3_superuser : []
}
