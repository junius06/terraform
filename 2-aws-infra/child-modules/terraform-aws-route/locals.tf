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

locals {
  route_table_ids = merge(
    {
      for key, route_table in aws_route_table.public :
      route_table.tags["Name"] => route_table.id
    },
    {
      for key, route_table in aws_route_table.private :
      route_table.tags["Name"] => route_table.id
    }
  )
}