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