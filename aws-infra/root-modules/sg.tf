module "sg" {
  source = "../child-modules/terraform-aws-sg"

  context = local.context

  security_groups = {
    for key, sg in local.security_groups :

    key => {
      name = sg.name

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

    #   source_type = rule.source_type
    #   source      = rule.source
    
      description = rule.description

      referenced_security_group_id = null
    }
  }

  common_tags = local.common_tags
}