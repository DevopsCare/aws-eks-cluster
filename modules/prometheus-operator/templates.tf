data "template_file" "prometheus-operator-values" {
  template = "${file("${path.module}/templates/prometheus-operator-values.yaml.tpl")}"

  vars {
    grafana_ingress_name = "${var.grafana_ingress_name}"
    domain               = "${var.domain}"

    keycloak_enabled = "${var.keycloak_enabled}"
    keycloak_domain  = "${var.keycloak_domain}"
    client_secret    = "${var.keycloak_client_secret}"
    namespace        = "${var.prometheus_operator_namespace}"
    oauth_proxy      = "${var.oauth_proxy_address}"
  }
}
