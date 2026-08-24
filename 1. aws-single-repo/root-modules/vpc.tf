# ============================================================
# MGMT
# ============================================================
module "mgmt_vpc" {
  source = "git@github.com:junius06/terraform-aws-vpc.git?ref=main"

  # child modules 와 레포지토리가 동일한 경우
  # source = "../child-modules/terraform-aws-vpc"

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
  source = "git@github.com:junius06/terraform-aws-vpc.git?ref=main"
  # source = "../child-modules/terraform-aws-vpc"

  name = "${var.project}-${var.environment}-${local.region_name}-svc"

  aws_region  = var.aws_region
  region_name = local.region_name
  region_code = local.region_code

  vpc_cidr    = var.svc_vpc_cidr

  public_subnet_cidrs = {}
  private_subnet_cidrs  = var.svc_private_subnet_cidrs

  create_internet_gateway   = false
  create_nat_gateway        = false

  create_s3_endpoint        = true
  create_ecr_endpoint       = true

  tags = merge(
    local.common_tags,
    {
      type    = "mgmt"
    }
  )
}

# ============================================================
# DB
# ============================================================
module "db_vpc" {
  source = "git@github.com:junius06/terraform-aws-vpc.git?ref=main"
  # source = "../child-modules/terraform-aws-vpc"

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
      type    = "mgmt"
    }
  )
}
