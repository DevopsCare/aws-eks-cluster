resource "random_string" "keycloak-password" {
  length  = 16
  special = false
}

data "template_file" "keycloak-values" {
  template = "${file("${path.module}/templates/keycloak-values.yaml.tpl")}"

  vars {
    ingress_name = "${var.keycloak_release_name}"
    username     = "${var.keycloak_username}"
    password     = "${var.keycloak_password == "" ? random_string.keycloak-password.*.result[0] : var.keycloak_password}"
  }
}
