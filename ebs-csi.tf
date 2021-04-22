module "ebs-csi-driver" {
  source  = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "2.4.0"

  enable_volume_resizing = true
  enable_volume_snapshot = true

  csi_controller_replica_count               = 1
  ebs_csi_controller_role_name               = "ebs-csi-driver-controller"
  ebs_csi_controller_role_policy_name_prefix = "ebs-csi-driver-policy"
  oidc_url                                   = module.eks.cluster_oidc_issuer_url
}

resource "kubernetes_storage_class" "ebs-sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    "csi.storage.k8s.io/fsType" = "xfs"
    "type"                      = "gp3"
  }
}
