module "route_table" {
  source = "../child-modules/terraform-aws-route"

  for_each = var.vpcs

  vpc_name = each.key
  vpc_id   = module.vpc[each.key].vpc_id

  public_subnets  = module.vpc[each.key].public_subnet_id
  private_subnets = module.vpc[each.key].private_subnet_id

  igw_id       = module.vpc[each.key].igw_id
  nat_gateways = module.vpc[each.key].nat_id

  context     = local.context
  common_tags = local.common_tags
}