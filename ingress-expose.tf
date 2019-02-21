resource "helm_repository" "jx" {
  name = "jx"
  url  = "http://chartmuseum.jenkins-x.io"
}

resource "helm_release" "ingress" {
  name      = "nginx-ingress"
  chart     = "stable/nginx-ingress"
  version   = "1.1.5"
  namespace = "kube-system"
  values    = ["${file("${path.module}/values/nginx.yaml")}"]

  set = {
    name  = "dummy.depends_on"
    value = "${module.eks.cluster_id}"
  }

  set = {
    name  = "controller.service.loadBalancerSourceRanges"
    value = "{${join(",", concat(var.ip_whitelist, local.github_meta_hooks, local.atlassian_inbound))}}"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}

// TODO this creates a job. we would want a daemon!
resource "helm_release" "expose" {
  name   = "expose"
  chart  = "jx/exposecontroller"
  values = ["${file("${path.module}/values/expose.yaml")}"]

  set = {
    name  = "dummy.depends_on"
    value = "${module.eks.cluster_id}"
  }

  set = {
    name  = "config.domain"
    value = "${var.project_fqdn}"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
