module "ebs_csi_driver_controller" {
  # TODO change to "DrFaust92/ebs-csi-driver/kubernetes" when TF14 matches
  source = "git::https://github.com/DevopsCare/terraform-kubernetes-ebs-csi-driver"

  csi_controller_replica_count               = 1
  ebs_csi_controller_role_name               = "ebs-csi-driver-controller"
  ebs_csi_controller_role_policy_name_prefix = "ebs-csi-driver-policy"
  oidc_url                                   = module.eks.cluster_oidc_issuer_url
}
