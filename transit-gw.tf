// TODO waiting for https://github.com/terraform-providers/terraform-provider-aws/issues/6670
/*resource "aws_ec2_transit_gateway_vpc_attachment" "eks-vpc" {
  subnet_ids         = ["${module.vpc.private_subnets}"]
  transit_gateway_id = "${var.shared_tgw_id}"
  vpc_id             = "${module.vpc.vpc_id}"
}*/

resource "aws_route" "private-route" {
  count                  = "${length(module.vpc.private_route_table_ids)}"
  route_table_id         = "${element(module.vpc.private_route_table_ids, count.index)}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${var.shared_tgw_id}"
}

resource "aws_route" "public-route" {
  count                  = "${length(module.vpc.public_route_table_ids)}"
  route_table_id         = "${element(module.vpc.public_route_table_ids, count.index)}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${var.shared_tgw_id}"
}
