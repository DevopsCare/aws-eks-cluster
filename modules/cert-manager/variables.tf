variable "aws_region" {
  type = "string"
}

variable "certmanager_chart_version" {
  default = "v0.6.0"
}

variable "certmanager_namespace" {
  default = "kube-system"
}

variable "certmanager_release_name" {
  default = "cert-manager"
}

variable "email" {
  description = "Email will be used for letsencrypt registration"
  type        = "string"
}

variable "kubeconfig" {
  type = "string"
}

variable "staging" {
  default = false
}
