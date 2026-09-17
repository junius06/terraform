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

  # 하나 이상의 VPC가 Additional Route 사용하면 CSV 로드
  additional_routes = anytrue([
    for vpc in values(var.vpcs) : # enable_additional_routes=false일 경우 안 읽고, true일 경우 csv파일을 decode > read 
    vpc.enable_additional_routes
  ]) ? csvdecode(file("${path.module}/route/route_table.csv")) : []

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
    }
    if peering.enable
  ]...)

#   # ECR
#   ecr_repository_arns = [
#     for repository_name in var.ecr_repositories :
#     "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${repository_name}"
#   ]

#   # S3
#   s3_bucket_arns = flatten([
#     for bucket_name in var.s3_buckets : [
#       "arn:aws:s3:::${bucket_name}",
#       "arn:aws:s3:::${bucket_name}/*"
#     ]
#   ])

  # TAGS
  common_tags = {
    # Project      = var.project
    Environment  = var.environment
    ManagedBy    = "Terraform"
  }
}