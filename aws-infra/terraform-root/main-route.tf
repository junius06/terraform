# 완료 -> Public & Private Nat 구분하여 라우팅 구성 필요
locals {
  routes = { for file in fileset("./route", "*.csv") :
    trimsuffix(replace(replace(replace(file, "{ENV}", var.ENV), "{REGION}", var.REGION), "rtb", "vpc"), ".csv") => { route_rules = csvdecode(file("./route/${file}")) }
  }
}

module "route" {
  source = "git@github.ecodesamsung.com:FMM-OPERATION/terraform-aws-global-route.git?ref=main"

  for_each = local.routes

  # 라우팅 테이블 룰(CSV 추출)
  route_rules = each.value.route_rules

  # Private 라우팅 테이블 정보
  pri_route_table_info = module.vpc[each.key].pri_rtb

  # 라우팅 테이블의 라우팅 대상
  # 생성된 NAT 정보
  target_nat_exist = try(module.vpc[each.key].target_nat_exist, [])
  target_nat_info  = try(module.vpc[each.key].target_nat_info, null)

  # 생성된 TGW Attachment 정보
  target_tgwa_exist = try(module.tgwa[each.key].target_tgwa_exist, [])
  target_tgwa_info  = try(module.tgwa[each.key].target_tgwa_info, null)

  # 생성된 GWLB Endpoint 정보
  target_gwlb_ep_exist = try(module.vpce_gwlb[each.key].target_gwlb_ep_exist, [])
  target_gwlb_ep_info  = try(module.vpce_gwlb[each.key].target_gwlb_ep_info, null)

  # 생성된 VPC Peer US 정보 - requester 기준
  target_vpc_peer_exist_us = try(module.vpc_peer[each.key].target_vpc_peer_exist_us, [])
  target_vpc_peer_info_us  = try(module.vpc_peer[each.key].target_vpc_peer_info_us, null)

  # 생성된 VPC Peer EU 정보 - requester 기준
  target_vpc_peer_exist_eu = try(module.vpc_peer[each.key].target_vpc_peer_exist_eu, [])
  target_vpc_peer_info_eu  = try(module.vpc_peer[each.key].target_vpc_peer_info_eu, null)
}

#######################################################
# GWLB Endpoint & TGW Attachment & VPC Peering 모듈 사용하지 않을 시, 임시로 생성 필요
#######################################################
module "vpce_gwlb" {
  source = "../"
}

module "tgwa" {
  source = "../"
}

# module "vpc_peer" {
#   source = "../"
# }