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
