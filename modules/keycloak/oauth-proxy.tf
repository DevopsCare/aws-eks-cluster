resource "helm_release" "oauth-proxy" {
  name      = "${var.oauth_proxy_release_name}"
  chart     = "stable/oauth2-proxy"
  namespace = "${var.oauth_proxy_namespace}"
  values    = ["${data.template_file.oauth-proxy-values.rendered}"]
  version   = "${var.oauth_proxy_chart_version}"

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
