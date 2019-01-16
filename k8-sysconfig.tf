provider "kubernetes" {
  config_path = "${path.root}/kubeconfig_${local.cluster_name}"
}

provider "helm" {
  service_account = "eks-admin"

  kubernetes = {
    config_path = "${path.root}/kubeconfig_${local.cluster_name}"
  }
}

resource "helm_repository" "coreos" {
  name = "coreos"
  url  = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
}

resource "kubernetes_service_account" "eks-admin" {
  depends_on = ["module.eks"]

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

resource "helm_release" "auto-scaler" {
  name      = "auto-scaler"
  chart     = "stable/cluster-autoscaler"
  namespace = "kube-system"
  values    = ["${file("${path.module}/values/autoscaler.yaml")}"]

  set = {
    name  = "dummy.depends_on"
    value = "${module.eks.cluster_id}"
  }

  set = {
    name  = "awsRegion"
    value = "${var.aws_region}"
  }

  set = {
    name  = "autoDiscovery.clusterName"
    value = "${local.cluster_name}"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name      = "kubernetes-dashboard"
  chart     = "stable/kubernetes-dashboard"
  version   = "0.10.2"    // Until https://github.com/helm/charts/issues/10714
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

resource "helm_release" "external-dns" {
  name      = "external-dns-public"
  chart     = "stable/external-dns"
  namespace = "default"
  values    = ["${file("${path.module}/values/external-dns.yaml")}"]

  set = {
    name  = "dummy.depends_on"
    value = "${module.eks.cluster_id}"
  }

  set = {
    name  = "aws.region"
    value = "${var.aws_region}"
  }

  set = {
    name  = "txtOwnerId"
    value = "${var.project_prefix}-dns-public"
  }

  lifecycle {
    ignore_changes = ["keyring"]
  }
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

// TODO
// kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
resource "kubernetes_storage_class" "gp2" {
  depends_on = ["module.eks"]

  metadata {
    name = "gp2"

    annotations = {
      // TODO "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "kubernetes.io/aws-ebs"

  parameters {
    type = "gp2"
  }
}
