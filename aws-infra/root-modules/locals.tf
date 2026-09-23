######################################
# 공통 변수
######################################
locals {
  region_map = {
    "eu-west-1" = {
      name   = "ireland"
      code   = "ew1"
      prefix = "eu"
    }

    "us-west-2" = {
      name   = "oregon"
      code   = "uw2"
      prefix = "us"
    }
  }

  region_name   = local.region_map[var.region].name
  region_code   = local.region_map[var.region].code
  region_prefix = local.region_map[var.region].prefix # uw2, ew1 등

  context = {
    project = var.project
    environment = var.environment
    region      = var.region
    region_name = local.region_name
  }

  # TAGS
  common_tags = {
    # Project      = var.project
    Environment  = var.environment
    ManagedBy    = "Terraform"
  }
}

######################################
# VPC Peering
######################################
locals {
  vpc_peerings = merge([
    for requester_alias, vpc in var.vpcs : {
      for accepter_alias, peering in vpc.vpc_peerings :
      "${requester_alias}-${accepter_alias}" => merge(
        peering,
        {
          requester_vpc_alias = requester_alias
          accepter_vpc_alias = accepter_alias
        }
      ) 
      if peering.enable
    }
  ]...)
}

######################################
# Route Table ㅡ csv file
######################################
locals {
  # 하나 이상의 VPC가 Additional Route 사용하면 CSV 로드
  additional_routes = anytrue([
    for vpc in values(var.vpcs) : # enable_additional_routes=false일 경우 안 읽고, true일 경우 csv파일을 decode > read 
    vpc.enable_additional_routes
  ]) ? csvdecode(file("${path.module}/route_tables/${var.environment}-${local.region_prefix}.csv")) : []
}

######################################
# S3 Bucket
######################################
locals {
  s3_bucket_files = fileset("${path.module}/s3/buckets", "*.yaml")

  s3_buckets = {
    for file_name in local.s3_bucket_files :
    trimsuffix(file_name, ".yaml") => yamldecode(
      file("${path.module}/s3/buckets/${file_name}")
    )
    if file_name != "__example.yaml"
  }
}