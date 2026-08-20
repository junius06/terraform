locals {
  vpc_peers = { for file in fileset("./vpc_peer", "*.yaml") :
    trimsuffix(replace(replace(file, "{environment}", var.environment), "{region_code}", var.region_code), ".yaml") => yamldecode(replace(replace(
      file("./vpc_peer/${file}"),
      "{environment}", var.environment
      ),
      "{region_code}", var.region_code)
  ) }
}

module "vpc_peer" {
  source = "git@github.ecodesamsung.com:OPERATION/terraform-aws-global-vpc-peer.git?ref=main"

  providers = {
    aws.us-accepter = aws.us-accepter
    aws.eu-accepter = aws.eu-accepter
  }

  for_each = { for k, v in local.vpc_peers : v.vpc_peer_requester_config.requester_vpc => v... } # requester_vpc

  vpc_peer_info = { for k, v in local.vpc_peers : k => {
    vpc_peer_name = v.vpc_peer_name
    vpc_peer_requester_config = {
      requester_vpc     = try(module.vpc[v.vpc_peer_requester_config.requester_vpc].vpc_id, v.vpc_peer_requester_config.requester_vpc)
      requester_account = try(v.vpc_peer_requester_config.requester_account, "")
      requester_region_code  = try(v.vpc_peer_requester_config.requester_region_code, "")
    }
    vpc_peer_accepter_config = {
      accepter_vpc     = try(module.vpc[v.vpc_peer_accepter_config.accepter_vpc].vpc_id, v.vpc_peer_accepter_config.accepter_vpc)
      accepter_account = try(v.vpc_peer_accepter_config.accepter_account, "")
      accepter_region_code  = try(v.vpc_peer_accepter_config.accepter_region_code, "")
    }
    vpc_peer_sub_tags = v.vpc_peer_sub_tags
    }
  }
}