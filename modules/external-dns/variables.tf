variable "aws_region" {
  type = "string"
}

variable "external_dns_additional_settings" {
  default = ""
}

variable "external_dns_chart_version" {
  default = "1.3.2"
}

variable "external_dns_enabled" {
  default = 1
}

variable "external_dns_namespace" {
  default = "kube-system"
}

variable "external_dns_release_name" {
  default = "external-dns"
}

variable "external_dns_txt_owner_id" {
  description = "Specify owner which will be put into TXT record"
  default     = ""
}

variable "kubeconfig" {
  type = "string"
}
