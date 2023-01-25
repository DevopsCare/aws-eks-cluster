/*
* Copyright (c) 2020 Risk Focus Inc.
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

output "eks_cluster" {
  value = module.eks
}

output "kubernetes_host" {
  value = module.eks.cluster_endpoint
}

output "kubernetes_ca_certificate" {
  value = base64decode(module.eks.cluster_certificate_authority_data)
}
