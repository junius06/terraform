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

  ipa_users = {
    dev = "fmmsysops.fmm-dev"
    stg = "fmmsysops.fmm-stg"
    prd = "fmmsysops.fmm-prod"
  }
  ipa_user = local.ipa_users[var.environment]

  context = {
    project = var.project
    environment = var.environment
    region      = var.region
    region_name = local.region_name
  }

  naming_rule = "${var.project}-${var.environment}-${local.region_name}"

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

######################################
# EC2
######################################
locals {
  key_name = (
    try(config.key_name.suffix, null) != null
    ? "${local.naming_rule}-${config.key_name.suffix}"
    : null
  )

  # ec2 생성하기 위한 yaml파일 탐색
  ec2_files = [
    for file_name in fileset("${path.module}/ec2", "*.yaml")
    : file_name if file_name != "example.yaml"
  ]

  # yaml 파일명을 EC2 종류의 논리적 이름으로 변환
  ## ex) `example.yaml` 파일 이름을 local.ec2_definitions["example"] 로 변환
  ec2_definitions = {
    for file_name in local.ec2_files :

    trimsuffix(file_name, ".yaml") => yamldecode(
      file("${path.module}/ec2/${file_name}")
    )
  }

  ## EC2 Validation
  # check "ec2_count_and_zones" {
  #   assert {
  #     condition = alltrue([
  #       for ec2_name, config in local.ec2_definitions :
  #       config.ec2_count > 0 &&
  #       config.ec2_count <= length(config.zones)
  #     ])

  #     error_message = "Each EC2 definition must have ec2_count > 0 and enough zones for ec2_count."
  #   }
  # }
}

locals {
  ec2_instances = merge(
    {},
    [
      for ec2_name, config in local.ec2_definitions : {
        for index in range(config.ec2_count) :
      }
    ]
  )
}