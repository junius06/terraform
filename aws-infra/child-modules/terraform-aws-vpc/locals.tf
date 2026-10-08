locals {
  public_subnet_map = merge([
    for subnet_name, group in var.public_subnets : {
      for subnet_zone, subnet_cidr in group.cidrs :
      "${subnet_name}-${subnet_zone}" => {
        subnet_name = subnet_name
        zone        = subnet_zone
        cidr        = subnet_cidr
      }
    }
  ]...)

  private_subnet_map = merge([
    for subnet_name, group in var.private_subnets : {
      for subnet_zone, subnet_cidr in group.cidrs :
      "${subnet_name}-${subnet_zone}" => {
        subnet_name = subnet_name
        zone        = subnet_zone
        cidr        = subnet_cidr
        enable_nat  = group.enable_nat
      }
    }
  ]...)
  # merge()는 list가 아니라 여러 개의 map/object를 인자로 받는다.
  # 그 때문에 끝에 "..."를 추가하여 list를 펼쳐서 하나의 평평한 map으로 변환한다.
  
  nat_subnet_map = {
    for key, subnet in local.public_subnet_map : 
    key => subnet
    if contains(var.nat_gateway_subnets, subnet.subnet_name)
  }
}
# root-modules/vpc 에서 받아온 public_subnets, private_subnets, nat_subnets 변수 값들과 혼동되지 않도록,
# flatten된 local에서는 `_map`를 추가한다.