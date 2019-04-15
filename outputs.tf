output "kubeconfig_filename" {
  value = "${module.eks.kubeconfig_filename}"
}

output "whitelist_sg_id" {
  value = "${aws_security_group.whitelist.id}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
