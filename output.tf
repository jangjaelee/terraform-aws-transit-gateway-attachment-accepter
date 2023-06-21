output "tgw_aa_id" {
  value = element(concat(aws_ec2_transit_gateway_vpc_attachment_accepter.this.*.id, [""]), 0)
}

output "tgw_aa_tags_all" {
  value = element(concat(aws_ec2_transit_gateway_vpc_attachment_accepter.this.*.tags_all, [""]), 0)
}

output "tgw_aa_appliance_mode_support" {
  value = element(concat(aws_ec2_transit_gateway_vpc_attachment_accepter.this.*.appliance_mode_support, [""]), 0)
}

output "tgw_aa_dns_support" {
  value = element(concat(aws_ec2_transit_gateway_vpc_attachment_accepter.this.*.dns_support, [""]), 0)
}

output "tgw_aa_ipv6_support" {
  value = element(concat(aws_ec2_transit_gateway_vpc_attachment_accepter.this.*.ipv6_support, [""]), 0)
}

output "tgw_aa_subnet_ids" {
  value = element(concat(aws_ec2_transit_gateway_vpc_attachment_accepter.this.*.subnet_ids, [""]), 0)
}

output "tgw_aa_transit_gateway_id" {
  value = element(concat(aws_ec2_transit_gateway_vpc_attachment_accepter.this.*.transit_gateway_id, [""]), 0)
}

output "tgw_aa_vpc_id" {
  value = element(concat(aws_ec2_transit_gateway_vpc_attachment_accepter.this.*.vpc_id, [""]), 0)
}

output "tgw_aa_vpc_owner_id" {
  value = element(concat(aws_ec2_transit_gateway_vpc_attachment_accepter.this.*.vpc_owner_id, [""]), 0)
}