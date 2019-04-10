data "template_file" "prometheus-operator-values" {
  template = "${file("${path.module}/templates/prometheus-operator-values.yaml.tpl")}"

  vars {
    client_secret        = "${var.keycloak_client_secret}"
    domain               = "${var.domain}"
    grafana_ingress_name = "${var.grafana_ingress_name}"
    namespace            = "${var.prometheus_operator_namespace}"
    keycloak_domain      = "${var.keycloak_domain}"
    oauth_proxy          = "${var.oauth_proxy_address}"
  }
}
