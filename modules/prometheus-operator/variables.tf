variable "domain" {
  type = "string"
}

variable "grafana_ingress_name" {
  default = "grafana"
}

variable "keycloak_domain" {
  type = "string"
}

variable "keycloak_client_secret" {
  type = "string"
}

variable "oauth_proxy_address" {
  description = "OAuth proxy address"
}

variable "prometheus_operator_chart_version" {
  default = "5.0.6"
}

variable "prometheus_operator_namespace" {
  default = "monitoring"
}

variable "prometheus_operator_release_name" {
  default = "prometheus-operator"
}
