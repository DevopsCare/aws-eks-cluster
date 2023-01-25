resource "kubernetes_storage_class" "ebs-csi-default" {
  metadata {
    name = "gp3"
    annotations = {
        "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  allow_volume_expansion = true
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "gp3"
  }
}
