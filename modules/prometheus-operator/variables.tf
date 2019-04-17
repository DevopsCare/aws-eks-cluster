variable "domain" {
  type = "string"
}

variable "grafana_ingress_name" {
  default = "grafana"
}

// Keycloak
variable "keycloak_enabled" {
  default = false
}
variable "keycloak_domain" {
  type = "string"
  default = ""
}
variable "keycloak_client_secret" {
  type = "string"
  default = ""
}
variable "oauth_proxy_address" {
  description = "OAuth proxy address"
  default = ""
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
