output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = {
    for key, subnet in aws_subnet.public : 
    key => {
      id          = subnet.id
      subnet_name = local.public_subnet_map[key].subnet_name
      zone        = local.public_subnet_map[key].zone
      cidr        = local.public_subnet_map[key].cidr
    }
  }
}

output "private_subnet_id" {
  value = {
    for key, subnet in aws_subnet.private  :
    key => {
      id          = subnet.id
      subnet_name = local.private_subnet_map[key].subnet_name
      zone        = local.private_subnet_map[key].zone
      cidr        = local.private_subnet_map[key].cidr
      enable_nat  = local.private_subnet_map[key].enable_nat
    }
  }
}

output "igw_id" {
  value = try(aws_internet_gateway.igw[0].id, null)
}

# output "nat_eip_id" {
#   value = 
# }

output "nat_id" {
  value = {
    for key, nat in aws_nat_gateway.nat :
    key => {
      id          = nat.id
      subnet_name = local.nat_subnet_map[key].subnet_name
      zone        = local.nat_subnet_map[key].zone
    }
  }
}