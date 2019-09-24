resource "kubernetes_service_account" "eks-admin" {
  metadata {
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "eks-admin--cluster-admin" {
  depends_on = [kubernetes_service_account.eks-admin]

  metadata {
    name = "cluster-admin--kube-system-eks-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

resource "null_resource" "gp2" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl patch --kubeconfig ${var.config_output_path}/kubeconfig_${var.project_prefix}-eks-cluster storageclass gp2 -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
EOT

  }
}

