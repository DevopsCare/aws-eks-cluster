output "keycloak-username" {
  value = "${var.keycloak_username}"
}

output "keycloak-password" {
  value = "${var.keycloak_password == "" ? random_string.keycloak-password.*.result[0] : var.keycloak_password}"
}
