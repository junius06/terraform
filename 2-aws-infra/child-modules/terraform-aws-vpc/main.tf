locals {
  naming_rule = "${var.context.project}-${var.context.environment}-${var.context.region_name}"
}

###################################### 
# VPC
######################################
resource "aws_vpc" "this" {
  cidr_block            = var.vpc_cidr

  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support

  tags = merge(
    var.common_tags,
    {
      Name = "${local.naming_rule}-${var.vpc_name}-vpc"
    }
  )
}

###################################### 
# VPC FLOW LOG
######################################
# resource "aws_flow_log" "this" {
#   for_each = var.vpc_flow_log_s3_name
# }

###################################### 
# PUBLIC SUBNET
######################################
resource "aws_subnet" "public" {
  for_each = local.public_subnet_map

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = "${var.context.region}${each.value.zone}"

  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${local.naming_rule}-${each.value.subnet_name}-pub-${each.value.zone}"
    }
  )
}

###################################### 
# PRIVATE SUBNET
######################################
resource "aws_subnet" "private" {
  for_each = local.private_subnet_map

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = "${var.context.region}${each.value.zone}"

  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${local.naming_rule}-${each.value.subnet_name}-pri-${each.value.zone}"
    }
  )
}

###################################### 
# INTERNET GATEWAY
######################################
resource "aws_internet_gateway" "igw" {
  count = length(local.public_subnet_map) > 0 ? 1 : 0 # public_subnet이 1개 이상일 경우 igw생성

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.naming_rule}-${var.vpc_name}-igw"
    }
  )
}

###################################### 
# EIP for NAT GATEWAY
######################################
resource "aws_eip" "nat_eip" {
  for_each = local.nat_subnet_map

  domain = "vpc"

  # NAT EIP 삭제 방지
  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${local.naming_rule}-${var.vpc_name}-nat-eip-${each.value.zone}"
    }
  )
}

###################################### 
# NAT GATEWAY
######################################
resource "aws_nat_gateway" "nat" {
  for_each = local.nat_subnet_map

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.naming_rule}-${var.vpc_name}-nat-${each.value.zone}"
    }
  )

  # IGW dependency 설정 (IGW생성 이후 NAT Gateway생성)
  depends_on = [ aws_internet_gateway.igw ]
}

###################################### 
# Additional Route Resource
######################################
resource "aws_route" "peering" {
  for_each = {
    for route in var.additional_routes :
    route.id => route
    if route.target_type == "peering"
  }

  route_table_id = local.route_table_ids[
    each.value.route_table
  ]

  destination_cidr_block = each.value.dst_cidr_block[
    each.value.target
  ]
}