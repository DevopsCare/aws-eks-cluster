# TODO: custom issuers with settings and count
data "template_file" "issuers" {
  template = "${file("${path.module}/templates/issuers.yaml.tpl")}"

  vars {
    email      = "${var.email}"
    aws_region = "${var.aws_region}"
  }
}
