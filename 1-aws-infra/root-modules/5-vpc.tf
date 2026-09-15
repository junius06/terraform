######################################
# MGMT VPC
######################################
# module "mgmt_vpc" {
#   source = "../child-modules/terraform-aws-vpc"

#   name = "${var.project}-${var.environment}-${local.region_name}-mgmt"

#   aws_region  = var.aws_region
#   region_name = local.region_name
#   region_code = local.region_code

#   vpc_cidr    = var.mgmt_vpc_cidr

#   public_subnet_cidrs  = var.mgmt_public_subnet_cidrs
#   private_subnet_cidrs = {}

#   create_internet_gateway   = true
#   create_nat_gateway        = false

#   create_s3_endpoint        = false
#   create_ecr_endpoint       = false

#   tags = merge(
#     local.common_tags,
#     {
#       type    = "mgmt"
#     }
#   )
# }

######################################
# MAIN VPC
######################################
module "main_vpc" {
  source = "../child-modules/terraform-aws-vpc"

  # VPC 기본 설정
  vpc_name = "${var.project}-${var.environment}-${local.region_name}-main-vpc"
  vpc_cidr = var.main_vpc_cidr

  aws_region    = var.aws_region
  region_name   = local.region_name
  region_code   = local.region_code
  region_prefix = local.region_prefix

  enable_dns_support   = true
  enable_dns_hostnames = true

  # Public Subnet Groups
  #---------------------------#
  # mgmt : EKS Bastion 용도
  # ext  : NAT Gateway 배치
  # elb  : Internet-facing ABL
  #---------------------------#
  public_subnet_groups = var.main_public_subnet_groups

  # Private Subnet Groups
  #---------------------------#
  # svc  : Application workloads
  # ops  : Operation workloads
  # kpt  : auto scaling workloads
  #---------------------------#
  private_subnet_groups = var.main_private_subnet_groups

  # enable_vpc_flow_log          = true
  # vpc_flow_log_destination_arn = module.s3["main-vpc-flow-log"].bucket_arn

  create_internet_gateway  = true
  create_nat_gateway       = true
  nat_gateway_subnet_group = "ext" # NGW가 배치될 서브넷 지정

  ## VPC Endpoints
  # create_s3_endpoint      = true
  # create_ecr_endpoint     = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-${local.region_name}-main-vpc"
    }
  )
}

######################################
# DB VPC
######################################
# module "db_vpc" {
#   source = "../child-modules/terraform-aws-vpc"

#   name = "${var.project}-${var.environment}-${local.region_name}-db"

#   aws_region  = var.aws_region
#   region_name = local.region_name
#   region_code = local.region_code

#   vpc_cidr    = var.db_vpc_cidr

#   public_subnet_cidrs = {}
#   private_subnet_cidrs  = var.db_private_subnet_cidrs

#   create_internet_gateway   = false
#   create_nat_gateway        = false

#   create_s3_endpoint        = false
#   create_ecr_endpoint       = false

#   tags = merge(
#     local.common_tags,
#     {
#       type    = "db"
#     }
#   )
# }