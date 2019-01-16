resource "aws_route53_zone" "primary" {
  name     = "${var.project_fqdn}"
  tags     = "${local.route53_tags}"
}
