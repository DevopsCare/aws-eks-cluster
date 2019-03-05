resource "helm_release" "filebeat" {
  name      = "${var.release_name}"
  chart     = "stable/filebeat"
  namespace = "${var.filebeat_namespace}"
  values    = ["${data.template_file.values.rendered}"]
  version   = "${var.filebeat_chart_version}"

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
