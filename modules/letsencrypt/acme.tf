resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.email_address}"
}

resource "acme_certificate" "certificate" {
  account_key_pem = "${acme_registration.reg.account_key_pem}"
  common_name     = "${var.common_name}"

  subject_alternative_names = "${var.subject_alternative_names}"

  dns_challenge {
    provider = "route53"

    config {
      AWS_PROFILE        = "${var.aws_profile}"
      AWS_DEFAULT_REGION = "${var.aws_region}"
    }
  }
}

resource "aws_iam_server_certificate" "certificate" {
  name_prefix       = "${acme_certificate.certificate.certificate_domain}-"
  certificate_body  = "${acme_certificate.certificate.certificate_pem}"
  private_key       = "${acme_certificate.certificate.private_key_pem}"
  certificate_chain = "${acme_certificate.certificate.issuer_pem}"

  lifecycle {
    create_before_destroy = true
  }
}
