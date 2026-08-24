# locals {
#   vpcs = { for file in fileset("./vpc", "*.yaml") :
#     trimsuffix(replace(replace(file, "{environment}", var.environment), "{region_code}", var.region_code), ".yaml") => yamldecode(replace(replace(
#       file("./vpc/${file}"),
#       "{environment}", var.environment
#       ),
#       "{region_code}", var.region_code)
#   ) }
# }

# module "vpc" {
#   # child modules 레포지토리를 별도로 두었을 경우
#   # source = "git@github.com:junius06/terraform-aws-vpc.git?ref=main"

#   # child modules 와 레포지토리가 동일한 경우
#   source = "../../terraform-aws-vpc"

#   for_each = local.vpcs

#   region_code               = var.aws_region_code
#   vpc_name             = each.key
#   vpc_cidr             = each.value.vpc_cidr
#   enable_dns_support   = each.value.enable_dns_support
#   enable_dns_hostnames = each.value.enable_dns_hostnames

#   public_nat_gateway_subnets = each.value.public_nat_gateway_subnets

#   public_subnet  = each.value.public_subnet
#   private_subnet = each.value.private_subnet

#   vpc_flow_log_s3_name = each.value.vpc_flow_log_s3_name
# }

module "vpc" {
  # child modules 레포지토리를 별도로 두었을 경우
  # source = "git@github.com:junius06/terraform-aws-vpc.git?ref=main"

  # child modules 와 레포지토리가 동일한 경우
  source = "../../terraform-aws-vpc"

  environment = var.environment
  aws_region  = var.aws_region
  region_name = local.region_name
  region_code = local.region_code

  # vpc_name    = 
  vpc_cidr    = var.vpc_cidr

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat_gateway = true

  tags = {
    Project = var.project
  }
}