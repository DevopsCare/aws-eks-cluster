
/*
*Copyright (c) 2020 Risk Focus Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


data "aws_ami" "amazon-linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  # Amazon
  owners = ["137112412989"]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

resource "aws_instance" "bastion" {
  count         = var.enable_bastion ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.nano"
  subnet_id     = module.vpc.public_subnets[0]

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id,
    aws_security_group.bastion_incoming_ssh.id,
  ]

  key_name  = var.key_name
  user_data = file("${path.module}/files/bastion_ssh_keys.sh")
  tags      = local.bastion_tags

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_security_group" "allow_ssh_from_bastion" {
  name        = "${var.project_prefix}-eks-bastion_ssh_access"
  description = "Allow SSH from bastion"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
}

resource "aws_security_group" "bastion_incoming_ssh" {
  name        = "${var.project_prefix}-eks-bastion_incoming_ssh"
  description = "Allow SSH to bastion from world"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = var.ip_whitelist
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_prefix}-eks-bastion_sg"
  description = "Bastion SG"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1

    security_groups = [
      module.eks.worker_security_group_id,
    ]
  }
}
