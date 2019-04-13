data "helm_repository" "jx" {
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
    name  = "controller.config.whitelist-source-range"
    value = "${join("\\,", concat(var.ip_whitelist, local.github_meta_hooks, local.atlassian_inbound, module.vpc.nat_public_ips))}"
  }

  set = {
    name  = "controller.service.loadBalancerSourceRanges"
    value = "{${join(",", concat(var.ip_whitelist, local.github_meta_hooks, local.atlassian_inbound, formatlist("%s/32", module.vpc.nat_public_ips)))}}"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}

resource "helm_release" "expose-default" {
  name      = "expose-default"
  chart     = "jx/exposecontroller"
  namespace = "default"
  values    = ["${file("${path.module}/values/expose.yaml")}"]

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

resource "helm_release" "expose-monitoring" {
  name      = "expose-monitoring"
  chart     = "jx/exposecontroller"
  namespace = "monitoring"
  values    = ["${file("${path.module}/values/expose.yaml")}"]

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
