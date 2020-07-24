resource "aws_iam_role" "cad3_superuser" {
  count = var.cad3_superuser ? 1 : 0
  name  = "EKS-Role-Superuser-${var.project_prefix}"
  path  = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        },
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "AWS": "${module.eks.worker_iam_role_arn}"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "cad3_superuser" {
  count       = var.cad3_superuser ? 1 : 0
  name        = "Cad3Superuser-${var.project_prefix}"
  description = "Superuser Access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cad3_attach_superuser_policy" {
  count      = var.cad3_superuser ? 1 : 0
  role       = aws_iam_role.cad3_superuser[0].name
  policy_arn = aws_iam_policy.cad3_superuser[0].arn
}
