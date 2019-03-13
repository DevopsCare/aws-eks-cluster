resource "helm_repository" "coreos" {
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
  aws_region   = "${var.aws_region}"
  cluster_name = "${local.cluster_name}"
  kubeconfig   = "${var.config_output_path}/kubeconfig_${local.cluster_name}"
}

module "filebeat" {
  source                 = "modules/filebeat"
  elasticsearch_endpoint = "${module.elk.elasticsearch_endpoint}"
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
  aws_region                = "${var.aws_region}"
  external_dns_txt_owner_id = "${var.project_prefix}-dns-public"
  kubeconfig                = "${var.config_output_path}/kubeconfig_${local.cluster_name}"
}

resource "helm_release" "grafana" {
  name      = "grafana"
  chart     = "stable/grafana"
  namespace = "default"
  values    = ["${file("${path.module}/values/grafana.yaml")}"]

  set = {
    name  = "dummy.depends_on"
    value = "${module.eks.cluster_id}"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}

resource "helm_release" "prometheus" {
  name      = "prometheus"
  chart     = "stable/prometheus"
  namespace = "default"
  values    = ["${file("${path.module}/values/prometheus.yaml")}"]

  set = {
    name  = "dummy.depends_on"
    value = "${module.eks.cluster_id}"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
