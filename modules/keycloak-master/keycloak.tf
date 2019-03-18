resource "helm_release" "keycloak" {
  name      = "${var.keycloak_release_name}"
  chart     = "stable/keycloak"
  namespace = "${var.keycloak_namespace}"
  values    = ["${data.template_file.keycloak-values.rendered}"]
  version   = "${var.keycloak_chart_version}"

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
