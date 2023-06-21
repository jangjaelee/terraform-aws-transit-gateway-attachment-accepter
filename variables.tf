variable "region" {
  description = "List of Allowed AWS account IDs"
  type        = string
}

variable "account_id" {
  description = "Allowed AWS account IDs"
  type = list(string)
}

variable "prefix" {
  description = "prefix for aws resources and tags"
  type        = string
}

variable "tags" {
  description = "tag map"
  type        = map(string)
}

variable "create_tgw_auto_accepter" {
  description = "Controls if Transit Gateway Attachment Auto-Accepter should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "tgw_accepter_name" {
  description = "The name of the resource share"
  type        = string
}

variable "transit_gateway_attachment_id" {
  description = "The ID of the EC2 Transit Gateway Attachment to manage"
  type        = string
}

variable "transit_gateway_default_route_table_association" {
  description = "Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table"
  type        = bool
  default     = true
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Boolean whether the VPC Attachment should propagate routes with the EC2 Transit Gateway propagation default route table"
  type        = bool
  default     = true
}