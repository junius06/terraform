resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

# 서브넷 그룹을 개별 서브넷 단위로 변환 ㅡ 실제 aws_subnet이 반복 생성하기 용이하도록 가공
locals {
  public_subnets = merge([
    for group_name, group in var.var.public_subnet_groups : {
      for az, cidr in group.cidrs : 
      "${group_name}-${az}" => {
        group = group_name
        az    = az
        cidr  = cidr
      }
    }
  ]...)

  private_subnets = merge([
    for group_name, group in var.var.private_subnet_groups : {
      for az, cidr in group.cidrs :
      "${group_name}-${az}" => {
        group = group_name
        az    = az
        cidr  = cidr
      }
    }
  ]...)
}