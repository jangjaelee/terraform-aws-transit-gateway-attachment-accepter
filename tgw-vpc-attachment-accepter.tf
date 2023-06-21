resource "null_resource" "validate_module_name" {
  count = local.module_name == var.tags["TerraformModuleName"] ? 0 : "Please check that you are using the Terraform module"
}

resource "null_resource" "validate_module_version" {
  count = local.module_version == var.tags["TerraformModuleVersion"] ? 0 : "Please check that you are using the Terraform module"
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {
  count = var.create_tgw_auto_accepter && var.transit_gateway_attachment_id != "" ? 1 : 0

  transit_gateway_attachment_id                   = var.transit_gateway_attachment_id
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  tags = merge(
    var.tags, tomap(
      {"Name" = format("%s.%s", var.prefix, var.tgw_accepter_name)}
    )
  )
}