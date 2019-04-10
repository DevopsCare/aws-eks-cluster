resource "helm_release" "prometheus-operator" {
  name      = "${var.prometheus_operator_release_name}"
  chart     = "stable/prometheus-operator"
  namespace = "${var.prometheus_operator_namespace}"
  version   = "${var.prometheus_operator_chart_version}"
  values    = ["${data.template_file.prometheus-operator-values.rendered}"]

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
