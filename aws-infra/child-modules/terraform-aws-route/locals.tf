locals {
  naming_rule = "${var.context.project}-${var.context.environment}-${var.context.region_name}"
}

locals {
  # Public Route Table (Zone분리해서 생성X)
  public_route_table_groups = toset([
    for subnet in values(var.public_subnets) :
    subnet.subnet_name
  ])

  # NAT Route가 필요한 Private Subnet
  nat_enabled_private_subnets = {
    for key, subnet in var.private_subnets :
    key => subnet
    if subnet.enable_nat
  }

  # 각 Private Subnet과 동일한 AZ에 존재하는 NAT Gateway 검색
  nat_by_private_subnet = {
    for subnet_key, subnet in local.nat_enabled_private_subnets :
    subnet_key => [
      for nat_key, nat in var.nat_gateways :
      nat
      if nat.zone == subnet.zone
    ]
  }
}

# Route Table IDs
locals {
  route_table_ids = merge(
    # Public Subnet Route Table
    {
      for key, route_table in aws_route_table.public :
      "${key}-pub-rt" => route_table.id
    },
    # Private Subnet Route Table
    {
      for key, route_table in aws_route_table.private :
      "${var.private_subnets[key].subnet_name}-pri-${var.private_subnets[key].zone}-rt" => route_table.id
    }
  )
}