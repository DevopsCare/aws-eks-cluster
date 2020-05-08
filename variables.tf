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

variable "extra_policy_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

variable "cad3_superuser" {
  type    = bool
  default = false
}

variable "enable_bastion" {
  type    = bool
  default = false
}
