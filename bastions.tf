/*
* Copyright (c) 2020 Risk Focus Inc.
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

module "ec2_bastion" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.30.1"

  enabled = var.enable_bastion

  instance_type = "t4g.nano"
  ami_filter    = { name = ["amzn2-ami-hvm-2.*-arm64-gp2"] }
  subnets       = module.vpc.public_subnets
  key_name      = var.key_name
  vpc_id        = module.vpc.vpc_id

  user_data = [
    "sudo amazon-linux-extras install epel -y",
    "sudo yum -y install fail2ban || sudo yum -y install fail2ban",
    "sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local",
    "sudo sed -i \"s/^\\[sshd\\]/[sshd]\\nenabled=true/\" /etc/fail2ban/jail.local",
    "sudo systemctl enable --now fail2ban",
    "sudo systemctl restart fail2ban",

    "sudo pip3 install pproxy",
    "sudo /usr/local/bin/pproxy --daemon"
  ]

  security_group_rules = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    },
    {
      type        = "ingress"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = var.ip_whitelist
      description = "Allow whitelisted inbound"
    },
    {
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow inbound to SSH"
    }
  ]

  associate_public_ip_address = true
  zone_id                     = data.aws_route53_zone.project_fqdn.zone_id
  host_name                   = "bastion"

  name        = "bastion"
  environment = "${var.project_prefix}-infra"
}
