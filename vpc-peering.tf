data "aws_vpc" "shared_vpc" {
  provider = "aws.master"
  id       = "${var.shared_vpc_id}"
}

data "aws_route_tables" "shared_vpc_rts" {
  provider = "aws.master"
  vpc_id   = "${var.shared_vpc_id}"
}

// Our side
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = "${module.vpc.vpc_id}"
  peer_vpc_id   = "${var.shared_vpc_id}"
  peer_owner_id = "${data.aws_caller_identity.master.account_id}"
  auto_accept   = false

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "Shared VPC"
    Side = "Requester"
  }
}

resource "aws_route" "route" {
  count                     = "${length(module.vpc.private_route_table_ids)}"
  route_table_id            = "${element(module.vpc.private_route_table_ids, count.index)}"
  destination_cidr_block    = "10.0.0.0/8"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
}

// Master account side
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = "aws.master"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  auto_accept               = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "${var.project_fqdn}"
    Side = "Accepter"
  }
}

resource "aws_route" "accepter-route" {
  provider                  = "aws.master"
  count                     = "${length(data.aws_route_tables.shared_vpc_rts.ids)}"
  route_table_id            = "${data.aws_route_tables.shared_vpc_rts.ids[count.index]}"
  destination_cidr_block    = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection_accepter.peer.id}"
}
