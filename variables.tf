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

variable "project_prefix" {}
variable "project_fqdn" {}
variable "project_rev_fqdn" {}

variable "vpc_cidr" {
  type    = string
  default = "172.31.0.0/16"
}

variable "ip_whitelist" {
  type    = list(string)
  default = []
}

variable "config_output_path" {}

variable "kubectl_assume_role" {
  type    = string
  default = ""
}

variable "spot_price" {
  default = ""
}

variable "key_name" {
  type    = string
  default = ""
}

variable "eks_authorized_roles" {
  type    = list(string)
  default = []
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.large", "t3.2xlarge"]
}

variable "worker_groups" {
  type = list(map(string))
  default = [
    {
      instance_type = "t3.large"
    },
    {
      instance_type = "t3.2xlarge"
    }
  ]
}

variable "enable_bastion" {
  type    = bool
  default = false
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}

variable "cad3_superuser" {
  description = "Create IAM and EKS service account for superuser role"
  type        = bool
  default     = false
}
