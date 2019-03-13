data "aws_caller_identity" "current" {}

resource "aws_security_group" "es" {
  name        = "elasticsearch-${var.domain}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${var.ip_whitelist}",
    ]
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.domain}"
  elasticsearch_version = "${var.elasticsearch_version}"

  cluster_config {
    instance_count = "${var.instance_count}"
    instance_type  = "${var.instance_type}"
  }

  vpc_options {
    subnet_ids = ["${var.subnet_ids}"]
    security_group_ids = ["${aws_security_group.es.id}"]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "${var.ebs_size}"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"
        }
    ]
}
CONFIG

  tags {
    Domain = "${var.domain}"
  }

  depends_on = [
    "aws_iam_service_linked_role.es",
  ]  
}
