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

module "iam_assumable_role_admin" {
  source                     = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                    = "3.4.0"
  create_role                = var.cad3_superuser
  role_name                  = "eks-superuser"
  provider_url               = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  number_of_role_policy_arns = 1
  role_policy_arns           = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
