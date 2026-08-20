locals {
  cheack_nat_exist = {
    for k, v in var.route_rules : v.id => v
    if v.target_type == "nat" # var.target_nat_exist 에서 contain 함수로 리스트 내에 nat 리소스 존재 확인 
  }
  cheack_tgw_exist = {
    for k, v in var.route_rules : v.id => v
    if v.target_type == "tgw" # var.target_tgwa_exist 에서 contain 함수로 tgwa 리소스 존재 확인
  }
  cheack_gwlb_ep_exist = {
    for k, v in var.route_rules : v.id => v
    if v.target_type == "gwlb" # var.target_gwlb_ep_exist 에서 contain 함수로 gwlb ep 리소스 존재 확인
  }
  cheack_vpc_peer_exist_us = {
    for k, v in var.route_rules : v.id => v
    if v.target_type == "peer" # var.target_vpc_peer_exist_us 에서 contain 함수로 vpc peer 리소스 존재 확인
  }
  cheack_vpc_peer_exist_eu = {
    for k, v in var.route_rules : v.id => v
    if v.target_type == "peer" # var.target_vpc_peer_exist_eu 에서 contain 함수로 vpc peer 리소스 존재 확인
  }
}

resource "aws_route" "nat_route_rules" {
  for_each = { for index, rule in local.cheack_nat_exist : index => rule if rule.target_type == "nat" }

  route_table_id         = var.pri_route_table_info[each.value.route_table].id
  destination_cidr_block = each.value.dst_cidr_block
  nat_gateway_id         = var.target_nat_info[each.value.target].id
}

resource "aws_route" "tgw_route_rules" {
  for_each = { for index, rule in local.cheack_tgw_exist : index => rule if rule.target_type == "tgw" }

  route_table_id         = var.pri_route_table_info[each.value.route_table].id
  destination_cidr_block = each.value.dst_cidr_block
  transit_gateway_id     = var.target_tgwa_info[each.value.target].transit_gateway_id
}

resource "aws_route" "gwlb_route_rules" {
  for_each = { for index, rule in local.cheack_gwlb_ep_exist : index => rule if rule.target_type == "gwlb" }

  route_table_id         = var.pri_route_table_info[each.value.route_table].id
  destination_cidr_block = each.value.dst_cidr_block
  vpc_endpoint_id        = var.target_gwlb_ep_info[each.value.target].id
}

resource "aws_route" "vpc_peer_rules_us" {
  for_each = { for index, rule in local.cheack_vpc_peer_exist_us : index => rule if rule.target_type == "peer" && var.target_vpc_peer_exist_us != [] }

  route_table_id            = var.pri_route_table_info[each.value.route_table].id
  destination_cidr_block    = each.value.dst_cidr_block
  vpc_peering_connection_id = var.target_vpc_peer_info_us[each.value.target].id
}

resource "aws_route" "vpc_peer_rules_eu" {
  for_each = { for index, rule in local.cheack_vpc_peer_exist_eu : index => rule if rule.target_type == "peer" && var.target_vpc_peer_exist_eu != [] }

  route_table_id            = var.pri_route_table_info[each.value.route_table].id
  destination_cidr_block    = each.value.dst_cidr_block
  vpc_peering_connection_id = var.target_vpc_peer_info_eu[each.value.target].id
}
