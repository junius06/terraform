######################################
# VPC
######################################
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

  flow_log_destination_arn = module.s3["vpcflow"].bucket_arn

  depends_on = [ 
    module.s3
  ]

  context     = local.context
  common_tags = local.common_tags
}


######################################
# VPC PEER
######################################
module "vpc_peering" {
  source = "../child-modules/terraform-aws-vpc-peer"

  for_each = local.vpc_peerings

  requester_vpc_id = module.vpc[
    each.value.requester_vpc_alias
  ].vpc_id

  requester_vpc_alias = each.value.requester_vpc_alias

  accepter_vpc_id    = each.value.accepter_vpc_id
  accepter_vpc_alias = each.value.accepter_vpc_alias
  accepter_region    = each.value.accepter_region

  enable_cross_account = each.value.enable_cross_account
  accepter_account_id  = each.value.accepter_account_id

  context     = local.context
  common_tags = local.common_tags
}


######################################
# ROUTE
######################################
module "route_table" {
  source = "../child-modules/terraform-aws-route"

  for_each = var.vpcs

  vpc_name = each.key
  vpc_id   = module.vpc[each.key].vpc_id

  public_subnets  = module.vpc[each.key].public_subnet_id
  private_subnets = module.vpc[each.key].private_subnet_id

  create_internet_gateway = each.value.create_internet_gateway

  igw_id       = module.vpc[each.key].igw_id
  nat_gateways = module.vpc[each.key].nat_id

  additional_routes = each.value.enable_additional_routes ? [
    for route in local.additional_routes :
    route
    if route.vpc == each.key
  ] : []

  vpc_peering_ids = {
    for key, peering in local.vpc_peerings :
    peering.accepter_vpc_alias => module.vpc_peering[key].vpc_peering_connection_id
    if peering.requester_vpc_alias == each.key
  }

  context     = local.context
  common_tags = local.common_tags
}


######################################
# S3
######################################
module "s3" {
  source = "../child-modules/terraform-aws-s3"

  for_each = local.s3_buckets
  
  # YAML 파일명을 bucket의 논리적 이름으로 사용
  bucket_name = each.key

  object_ownership        = try(each.value.object_ownership, {})
  force_destroy           = try(each.value.force_destroy, {})
  block_all_public_access = try(each.value.block_all_public_access, {})
  versioning              = try(each.value.versioning, {})
  encryption              = try(each.value.encryption, {})
  lifecycle_config        = try(each.value.lifecycle, {})

  bucket_policy = (
    each.value.bucket_policy.enabled
    ? templatefile(
        "${path.module}/s3/bucket_policies/${coalesce(each.value.bucket_policy.name, each.key)}.json.tftpl",
        {
          bucket_arn = "arn:aws:s3:::${local.context.project}-${local.context.environment}-${local.context.region_name}-${each.key}"

          aws_account_id = data.aws_caller_identity.current.account_id
          aws_region     = local.context.region
        }
      )
    : null
  )

  context     = local.context
  common_tags = local.common_tags
}


######################################
# EC2
######################################
module "ec2" {
  source = "../child-modules/terraform-aws-ec2"
  
  instances = {
    for instance_name, instance in local.ec2_instances :

    instance_name => {
      #### Instance
      ami_id = data.aws_ssm_parameter.al2023_arm64.value
      instance_type = instance.instance_type

      key_name = instance.key_name

      iam_instance_profile = (
        instance.iam_instance_profile != null
        ? module.iam.instance_profile_names[
            instance.iam_instance_profile
          ]
        : null
      )

      monitoring = instance.monitoring

      #### Network
      subnet_id = (
        instance.network.subnet_type == "public"
        ? module.vpc[
          instance.network.vpc_name
        ].public_subnet_id[
          "${instance.network.subnet_group}-${instance.zone}"
        ].id
        : module.vpc[
          instance.network.vpc_name
        ].private_subnet_id[
          "${instance.network.subnet_group}-${instance.zone}"
        ].id
      )

      security_group_ids = [
        for sg_name in instance.security_groups :
        module.sg.security_group_ids[
          "${instance.network.vpc_name}/${sg_name}"
        ]
      ]

      associate_public_ip_address = (
        instance.associate_public_ip_address
      )

      #### Elastic IP
      eip = instance.eip

      #### User Data
      user_data =(
        instance.user_data_file != null
        ? file(
          "${path.module}/ec2/user-data/${instance.user_data_file}"
        )
        : null
      )

      #### Root & Additional EBS Volume
      root_volume = instance.root_volume
      ebs_volumes = instance.ebs_volumes

      #### Tags
      tags = instance.tags
    }
  }

  ipa_user = local.ipa_user
  common_tags = local.common_tags
}


######################################
# SG
######################################
module "sg" {
  source = "../child-modules/terraform-aws-sg"

  context = local.context

  security_groups = {
    for key, sg in local.security_groups :

    key => {
      sg_name = sg.sg_name

      description = "Security Group for ${sg.sg_name} in VPC ${sg.vpc_name}"

      vpc_id = module.vpc[sg.vpc_name].vpc_id
    }
  }

  rules = {
    for key, rule in local.sg_rules :
    key => {
      security_group_key = "${rule.vpc_name}/${rule.sg_name}"

      type        = rule.type
      protocol    = rule.protocol
      from_port   = rule.from_port
      to_port     = rule.to_port

      cidr_ipv4   = rule.source_type == "cidr" ? rule.source : null

      # source_type = rule.source_type
      # source      = rule.source
    
      description = rule.description

      referenced_security_group_id = null
    }
  }

  common_tags = local.common_tags
}


######################################
# IAM
######################################
module "iam" {
  source = "../child-modules/terraform-aws-iam"

  roles = local.iam_roles

  context = local.context
  common_tags = local.common_tags
}


######################################
# EKS
######################################
module "eks" {
  source = "../child-modules/terraform-aws-eks"

  cluster = local.eks_clusters

  context = local.context
  common_tags = local.common_tags
}


######################################
# VPC ENDPOINT
######################################

######################################
# VPCE ENDPOINT GATEWAY
######################################