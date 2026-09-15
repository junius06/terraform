######################################
# VPC
######################################
module "vpc" {
  source = "../child-modules/terraform-aws-vpc"

  for_each = var.vpcs

  context       = local.context

  vpc_name = each.key
  vpc_cidr = each.value.cidr

  public_subnet_groups     = each.value.public_subnet_groups
  private_subnet_groups    = each.value.private_subnet_groups
  nat_gateway_subnet_group = each.value.nat_gateway_subnet_group # NGW가 배치될 서브넷 지정

  enable_dns_support   = true
  enable_dns_hostnames = true

  common_tags = local.common_tags

  # create_internet_gateway  = true
  # create_nat_gateway       = true
  
  ## VPC Endpoints
  # create_s3_endpoint      = true
  # create_ecr_endpoint     = true

  # vpc_flow_log_s3_name = each.value.vpc_flow
}