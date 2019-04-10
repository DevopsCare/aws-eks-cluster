output "oauth-proxy-address" {
  value = "${var.oauth_ingress_name}.${var.oauth_proxy_namespace}.${var.root_domain}"
}

output "client-secret" {
  value = "${keycloak_openid_client.openid_client.client_secret}"
}

output "keycloak-subdomain" {
  value = "${var.keycloak_release_name}.${var.keycloak_namespace}"
}

output "keycloak-username" {
  value = "${var.keycloak_username}"
}

output "keycloak-password" {
  value = "${var.keycloak_password == "" ? random_string.keycloak-password.*.result[0] : var.keycloak_password}"
}
