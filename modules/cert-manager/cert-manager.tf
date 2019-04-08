resource "null_resource" "crd" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl apply --kubeconfig ${var.kubeconfig} -f ${path.module}/files/crd.yaml
    EOT
  }
}

resource "local_file" "issuers" {
  content  = "${data.template_file.issuers.rendered}"
  filename = "${path.module}/issuers.yaml"
}

resource "null_resource" "issuers" {
  triggers {
    issuers = "${local_file.issuers.id}"
  }

  provisioner "local-exec" {
    command = <<EOT
      kubectl apply --kubeconfig ${var.kubeconfig} -f ${path.module}/issuers.yaml
    EOT
  }

  depends_on = ["local_file.issuers", "null_resource.crd", "helm_release.certmanager"]
}

resource "helm_release" "certmanager" {
  name      = "${var.certmanager_release_name}"
  chart     = "stable/cert-manager"
  namespace = "${var.certmanager_namespace}"
  version   = "${var.certmanager_chart_version}"

  set {
    name = "webhook.enabled"

    # https://github.com/terraform-providers/terraform-provider-helm/issues/208
    value = "false"
  }

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "${var.staging ? "letsencrypt-staging" : "letsencrypt-prod"}"
  }

  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  set {
    name  = "ingressShim.defaultACMEChallengeType"
    value = "dns01"
  }

  set {
    name  = "ingressShim.defaultACMEDNS01ChallengeProvider"
    value = "aws"
  }

  depends_on = ["null_resource.crd"]

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
