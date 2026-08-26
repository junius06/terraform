# ============================================================
# MGMT
# ============================================================
module "mgmt_vpc" {
  source = "../child-modules/terraform-aws-vpc"

  name = "${var.project}-${var.environment}-${local.region_name}-mgmt"

  aws_region  = var.aws_region
  region_name = local.region_name
  region_code = local.region_code

  vpc_cidr    = var.mgmt_vpc_cidr

  public_subnet_cidrs  = var.mgmt_public_subnet_cidrs
  private_subnet_cidrs = {}

  create_internet_gateway   = true
  create_nat_gateway        = false

  create_s3_endpoint        = false
  create_ecr_endpoint       = false

  tags = merge(
    local.common_tags,
    {
      type    = "mgmt"
    }
  )
}

# ============================================================
# SVC
# ============================================================
module "svc_vpc" {
  source = "../child-modules/terraform-aws-vpc"

  name = "${var.project}-${var.environment}-${local.region_name}-svc"

  aws_region  = var.aws_region
  region_name = local.region_name
  region_code = local.region_code

  vpc_cidr    = var.svc_vpc_cidr

  public_subnet_cidrs              = {}
  eks_cluster_private_subnet_cidrs = var.eks_cluster_private_subnet_cidrs
  eks_node_subnet_groups           = var.svc_private_subnet_groups

  create_internet_gateway     = false

  create_s3_endpoint          = true
  create_ecr_endpoint         = true

  tags = merge(
    local.common_tags,
    {
      type    = "svc"
    }
  )
}

# ============================================================
# DB
# ============================================================
module "db_vpc" {
  source = "../child-modules/terraform-aws-vpc"

  name = "${var.project}-${var.environment}-${local.region_name}-db"

  aws_region  = var.aws_region
  region_name = local.region_name
  region_code = local.region_code

  vpc_cidr    = var.db_vpc_cidr

  public_subnet_cidrs = {}
  private_subnet_cidrs  = var.db_private_subnet_cidrs

  create_internet_gateway   = false
  create_nat_gateway        = false

  create_s3_endpoint        = false
  create_ecr_endpoint       = false

  tags = merge(
    local.common_tags,
    {
      type    = "db"
    }
  )
}