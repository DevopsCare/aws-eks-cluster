variable "keycloak_chart_version" {
  default = "4.6.1"
}

variable "keycloak_release_name" {
  default = "keycloak"
}

variable "keycloak_namespace" {
  default = "default"
}

variable "keycloak_username" {
  default = "keycloak"
}

variable "keycloak_password" {
  default = ""
}

variable "oauth_ingress_name" {
  default = "oauth"
}

variable "oauth_proxy_chart_version" {
  default = "0.11.0"
}

variable "oauth_proxy_release_name" {
  default = "oauth2-proxy"
}

variable "oauth_proxy_namespace" {
  default = "default"
}

variable "realm_name" {
  default = "weissr.click"
}

variable "root_domain" {
  type = "string"
}

variable "ldap_bind_dn" {
  type = "string"
}

variable "ldap_password" {
  type = "string"
}

variable "ldap_host" {
  type = "string"
}

variable "users_dn" {
  type = "string"
}
