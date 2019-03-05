resource "helm_release" "kibana" {
  count     = "${var.selfhosted_kibana_enabled}"
  name      = "${var.kibana_release_name}"
  chart     = "stable/kibana"
  namespace = "${var.kibana_namespace}"
  values    = ["${data.template_file.kibana-values.rendered}"]
  version   = "${var.kibana_chart_version}"

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
