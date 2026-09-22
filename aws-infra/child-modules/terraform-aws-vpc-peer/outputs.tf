output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.this.id
}

output "name" {
  description = "Logical name of the VPC peering connection"
  value       = var.requester_vpc_alias
}

output "requester_vpc_id" {
  description = "Requester VPC ID"
  value       = var.requester_vpc_id
}

output "accepter_vpc_alias" {
  description = "Logical alias of the accepter VPC"
  value       = var.accepter_vpc_alias
}
output "accepter_vpc_id" {
  description = "Accepter VPC ID"
  value       = var.accepter_vpc_id
}

output "accepter_region" {
  description = "Effective region og the accepter VPC"
  value       = local.accepter_region
}

output "cross_region" {
  description = "Whether the VPC peering connection is cross-region"
  value       = local.cross_region
}

output "cross_account" {
  description = "Whether the VPC peering connection is cross-account"
  value       = var.enable_cross_account
}