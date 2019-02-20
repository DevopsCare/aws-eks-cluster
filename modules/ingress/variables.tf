variable "aws_region" {
  type = "string"
}

variable "ingress_namespace" {
  default = "ingress"
}

variable "ingress_release_name" {
  default = "nginx-ingress"
}

variable "kubeconfig" {
  type = "string"
}

variable "nginx_chart_version" {
  default = "1.1.5"
}
