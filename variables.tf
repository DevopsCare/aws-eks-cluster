variable "aws_region" {}
variable "aws_profile" {}
variable "project_prefix" {}
variable "project_fqdn" {}
variable "project_rev_fqdn" {}

variable vpc_cidr {
  type    = "string"
  default = "172.31.0.0/16"
}

variable "ip_whitelist" {
  type    = "list"
  default = []
}

variable "config_output_path" {}

variable "kubectl_assume_role" {
  default = ""
}

variable "spot_price" {
  default = "0.1"
}

variable key_name {
  type = "string"
}

variable extra_policy_arn {
  type    = "string"
  default = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
