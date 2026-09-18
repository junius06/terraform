module "vpc" {
  source = "../child-modules/terraform-aws-vpc"

  for_each = var.vpcs

  vpc_name = each.key
  vpc_cidr = each.value.cidr

  public_subnets      = each.value.public_subnets
  private_subnets     = each.value.private_subnets
  nat_gateway_subnets = each.value.nat_gateway_subnets

  enable_dns_support   = true
  enable_dns_hostnames = true
 
  # Private/Public Subnet이 생성되면 IGW, NAT 자동 생성되지만,
  # 아래의 변수를 false로 설정하면 생성되지 않도록 설정하는 장치 추가.
  # create_internet_gateway = true
  # create_nat_gateway      = true
  
  ## VPC Endpoints
  # create_s3_endpoint      = true
  # create_ecr_endpoint     = true

  # vpc_flow_log_s3_name = each.value.vpc_flow

  context     = local.context
  common_tags = local.common_tags
}