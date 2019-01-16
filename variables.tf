variable "aws_region" {}
variable "aws_profile" {}
variable "project_prefix" {}
variable "project_fqdn" {}
variable "project_rev_fqdn" {}

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
