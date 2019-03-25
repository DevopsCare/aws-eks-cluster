variable "aws_region" {
  type = "string"
}

variable "aws_profile" {
  type = "string"
}

variable "config_output_path" {
  type = "string"
}

variable "email" {
  description = "Email for registration in Letsencrypt"
  default     = "acme@example.com"
}

variable vpc_cidr {
  type    = "string"
  default = "172.31.0.0/16"
}

variable "ip_whitelist" {
  type    = "list"
  default = []
}

variable "keycloak_password" {
  default = ""
}

variable "keycloak_username" {
  default = "keycloak"
}

variable key_name {
  type = "string"
}

variable "kubectl_assume_role" {
  default = ""
}

variable "ldap_bind_dn" {
  type = "string"
}

variable "ldap_host" {
  type = "string"
}

variable "ldap_password" {
  type = "string"
}

variable "project_prefix" {}
variable "project_fqdn" {}
variable "project_rev_fqdn" {}

variable "spot_price" {
  default = "0.1"
}

variable extra_policy_arn {
  type    = "string"
  default = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

variable "shared_tgw_id" {
  type    = "string"
  default = ""
}

variable "users_dn" {
  type = "string"
}
