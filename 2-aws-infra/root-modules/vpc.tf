######################################
# VPC
######################################
module "vpc" {
  source = "../child-modules/terraform-aws-vpc"

  for_each = var.vpcs

  context = local.context

  vpc_name = each.key
  vpc_cidr = each.value.cidr

  public_subnet_groups     = each.value.public_subnet_groups
  private_subnet_groups    = each.value.private_subnet_groups

  enable_dns_support   = true
  enable_dns_hostnames = true

  additional_routes = each.value.enable_additional_routes ? [
    for route in local.additional_routes : route
    if route.vpc == each.key
  ] : []

  # Private/Public Subnet이 생성되면 IGW, NAT 자동 생성되지만,
  # 아래의 변수를 false로 설정하면 생성되지 않도록 설정하는 장치 추가.
  # create_internet_gateway = true
  # create_nat_gateway      = true
  
  ## VPC Endpoints
  # create_s3_endpoint      = true
  # create_ecr_endpoint     = true

  # vpc_flow_log_s3_name = each.value.vpc_flow

  common_tags = local.common_tags
}