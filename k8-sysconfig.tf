data "helm_repository" "coreos" {
  name = "coreos"
  url  = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
}

resource "kubernetes_service_account" "eks-admin" {
  metadata = {
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "eks-admin--cluster-admin" {
  depends_on = ["kubernetes_service_account.eks-admin"]

  metadata = {
    name = "cluster-admin--kube-system-eks-admin"
  }

  role_ref = {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject = {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

module "autoscaler" {
  source       = "modules/autoscaler"
  aws_region   = "${local.aws_region}"
  cluster_name = "${local.cluster_name}"
}

resource "helm_release" "overprovisioner" {
  name      = "overprovisioner"
  chart     = "stable/cluster-overprovisioner"
  namespace = "kube-system"
  values    = ["${file("${path.module}/values/overprovisioner.yaml")}"]

  set = {
    name  = "dummy.depends_on"
    value = "${module.eks.cluster_id}"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}

resource "helm_release" "metrics-server" {
  name      = "metrics-server"
  chart     = "stable/metrics-server"
  namespace = "kube-system"

  values = [
    "${file("${path.module}/values/metrics-server.yaml")}",
  ]

  set = {
    name  = "dummy.depends_on"
    value = "${module.eks.cluster_id}"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name      = "kubernetes-dashboard"
  chart     = "stable/kubernetes-dashboard"
  namespace = "kube-system"
  values    = ["${file("${path.module}/values/dashboard.yaml")}"]

  set = {
    name  = "dummy.depends_on"
    value = "${module.eks.cluster_id}"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}

module "external-dns" {
  source                    = "modules/external-dns"
  aws_region                = "${local.aws_region}"
  external_dns_txt_owner_id = "${var.project_prefix}-dns-public"
}

module "prometheus-operator" {
  source                 = "modules/prometheus-operator"
  domain                 = "${var.project_fqdn}"
  keycloak_client_secret = "${var.keycloak_client_secret}"
  keycloak_domain        = "${var.keycloak_domain}"
  oauth_proxy_address    = "${var.keycloak_oauth_proxy_address}"
}

resource "null_resource" "gp2" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl patch --kubeconfig ${var.config_output_path}/kubeconfig_${var.project_prefix}-eks-cluster storageclass gp2 -p {"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}
    EOT
  }
}
