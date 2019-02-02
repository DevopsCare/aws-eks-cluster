data "aws_caller_identity" "current" {}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.domain}"
  access_policies       = "${data.aws_iam_policy_document.elk_policy.json}"
  elasticsearch_version = "${var.elasticsearch_version}"

  cluster_config {
    instance_count = "${var.instance_count}"
    instance_type  = "${var.instance_type}"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "${var.ebs_size}"
  }

  tags {
    Domain = "${var.domain}"
  }
}

data "aws_iam_policy_document" "elk_policy" {
  statement {
    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = "${var.ip_whitelist}"
    }
  }
}
