locals {
  public_subnets = merge([
    for subnet_name, group in var.public_subnet_groups : {
      for subnet_zone, subnet_cidr in group.cidrs :

      "${subnet_name}-${subnet_zone}" => {
        subnet_name = subnet_name
        zone        = subnet_zone
        cidr        = subnet_cidr
      }
    }
  ]...)

  private_subnets = merge([
    for subnet_name, group in var.private_subnet_groups : {
      for subnet_zone, cidr in group.cidrs :

      "${subnet_name}-${subnet_zone}" => {
        subnet_name = subnet_name
        zone        = subnet_zone
        cidr        = subnet_cidr
        enable_nat  = group.enable_nat
      }
    }
  ]...)
}
# merge()는 list가 아니라 여러 개의 map/object를 인자로 받는다.
# 그 때문에 끝에 "..."를 추가하여 list를 펼쳐서 하나의 평평한 map으로 변환한다.