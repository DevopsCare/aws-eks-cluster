resource "helm_release" "ingress" {
  name      = "${var.ingress_release_name}"
  chart     = "stable/nginx-ingress"
  namespace = "${var.ingress_namespace}"
  version   = "${var.nginx_chart_version}"

  values = ["${file("${path.root}/values/nginx.yaml")}"]

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
