# PUBLIC ROUTE TABLES
output "public_route_tables" {
  description = "Public Route Table Information"

  value = {
    for key, route_table in aws_route_table.public :
    key => {
      id   = route_table.id
      Name = "${var.context.project}-${var.context.environment}-${var.context.region_name}-${key}-pub-rt"
    }
  }
}

# PRIVATE ROUTE TABLES
output "private_route_tables" {
  description = "Private Route Table Information"

  value = {
    for key, route_table in aws_route_table.private :
    key => {
        id          = route_table.id
        subnet_name = var.private_subnets[key].subnet_name
        zone        = var.private_subnets[key].zone
        Name        = "${var.context.project}-${var.context.environment}-${var.context.region_name}-${var.private_subnets[key].subnet_name}-pri-${var.private_subnets[key].zone}-rt"
    }
  }
}

# ROUTE TABLE IDs
output "route_table_ids" {
  description = "Map of logical Route Table names to Route Table IDs"
  value       = local.route_table_ids
}