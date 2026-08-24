terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 🔑 이 모듈이 부모로부터 받을 별칭들을 선언 (구성 자체는 부모에서 제공)
      # Warning: Reference to undefined provider 문제 해결
      # There is no explicit declaration for local provider name "aws.us-accepter" in module.vpc_peer, so Terraform is assuming you mean to pass a configuration for "hashicorp/aws".
      # If you also control the child module, add a required_providers entry named "aws.us-accepter" with the source address "hashicorp/aws".
      configuration_aliases = [
        aws.us-accepter,
        aws.eu-accepter
      ]
    }
  }
}

locals {
  requester_account = { for k, v in var.vpc_peer_info : k => v.vpc_peer_requester_config.requester_account }
  requester_region_code  = { for k, v in var.vpc_peer_info : k => v.vpc_peer_requester_config.requester_region_code }

  accepter_account = { for k, v in var.vpc_peer_info : k => v.vpc_peer_accepter_config.accepter_account }
  accepter_region_code  = { for k, v in var.vpc_peer_info : k => v.vpc_peer_accepter_config.accepter_region_code }

  is_cross_account = {
    for k, v in local.requester_account :
    k => (
      !contains(keys(local.accepter_account), k) || local.accepter_account[k] != v
    )
  }

  is_cross_region_code = {
    for k, v in local.requester_region_code :
    k => (
      !contains(keys(local.accepter_region_code), k) || local.accepter_region_code[k] != v
    )
  }

  need_accepter = {
    for k in distinct(concat(
      keys(local.is_cross_account),
      keys(local.is_cross_region_code)
    )) :
    k => (
      lookup(local.is_cross_account, k, false) || lookup(local.is_cross_region_code, k, false)
    )
  }
}

################################################################################
# VPC Peering Connection
################################################################################
resource "aws_vpc_peering_connection" "us_region_code" {
  for_each = { for k, v in var.vpc_peer_info : k => v if v.vpc_peer_requester_config.requester_region_code == "us-west-2" }

  peer_owner_id = local.is_cross_account[each.key] ? local.accepter_account[each.key] : null
  peer_region_code   = local.is_cross_region_code[each.key] ? local.accepter_region_code[each.key] : null

  vpc_id      = each.value.vpc_peer_requester_config.requester_vpc
  peer_vpc_id = each.value.vpc_peer_accepter_config.accepter_vpc

  auto_accept = local.need_accepter[each.key] ? false : true

  dynamic "requester" {
    for_each = local.need_accepter[each.key] ? toset([]) : toset(["1"])
    content {
      allow_remote_vpc_dns_resolution = true
    }
  }

  dynamic "accepter" {
    for_each = local.need_accepter[each.key] ? toset([]) : toset(["1"])
    content {
      allow_remote_vpc_dns_resolution = true
    }
  }

  tags = merge({ Name = each.key }, { Side = "Requester" }, try(each.value.vpc_peer_sub_tags, {}))
}

########### US 계정 요청 기준 #############

# need_accepter = true 인 경우에만 아래 코드들 실행
# us 기준에서 배포 시, eu 리전이 accepter 이므로  provider = aws.eu-accepter 으로 선언
################################################################################
# VPC Peering Accepter
################################################################################
resource "aws_vpc_peering_connection_accepter" "us_region_code" {
  for_each = { for k, v in var.vpc_peer_info : k => v if local.need_accepter[k] == true && v.vpc_peer_requester_config.requester_region_code == "us-west-2" }

  provider = aws.eu-accepter

  vpc_peering_connection_id = aws_vpc_peering_connection.us_region_code[each.key].id
  auto_accept               = true

  tags = merge({ Name = each.key }, { Side = "Accepter" }, try(each.value.vpc_peer_sub_tags, {}))
}


################################################################################
# VPC Peering Option
################################################################################
resource "aws_vpc_peering_connection_options" "us_region_code_requester" {
  for_each = { for k, v in var.vpc_peer_info : k => v if local.need_accepter[k] == true && v.vpc_peer_requester_config.requester_region_code == "us-west-2" }

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.us_region_code[each.key].id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

# us 기준에서 배포 시, eu 리전이 accepter 이므로  provider = aws.eu-accepter 으로 선언
resource "aws_vpc_peering_connection_options" "us_region_code_accepter" {
  for_each = { for k, v in var.vpc_peer_info : k => v if local.need_accepter[k] == true && v.vpc_peer_requester_config.requester_region_code == "us-west-2" }

  provider = aws.eu-accepter

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.us_region_code[each.key].id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}


########### EU 계정 요청 기준 #############

################################################################################
# VPC Peering Connection
################################################################################
resource "aws_vpc_peering_connection" "eu_region_code" {
  for_each = { for k, v in var.vpc_peer_info : k => v if v.vpc_peer_requester_config.requester_region_code == "eu-west-1" }

  peer_owner_id = local.is_cross_account[each.key] ? local.accepter_account[each.key] : null
  peer_region_code   = local.is_cross_region_code[each.key] ? local.accepter_region_code[each.key] : null

  vpc_id      = each.value.vpc_peer_requester_config.requester_vpc
  peer_vpc_id = each.value.vpc_peer_accepter_config.accepter_vpc

  auto_accept = local.need_accepter[each.key] ? false : true

  dynamic "requester" {
    for_each = local.need_accepter[each.key] ? toset([]) : toset(["1"])
    content {
      allow_remote_vpc_dns_resolution = true
    }
  }

  dynamic "accepter" {
    for_each = local.need_accepter[each.key] ? toset([]) : toset(["1"])
    content {
      allow_remote_vpc_dns_resolution = true
    }
  }

  tags = merge({ Name = each.key }, { Side = "Requester" }, try(each.value.vpc_peer_sub_tags, {}))
}

# need_accepter = true 인 경우에만 아래 코드들 실행
# eu 기준에서 배포 시, us 리전이 accepter 이므로  provider = aws.us-accepter 으로 선언
################################################################################
# VPC Peering Accepter
################################################################################
resource "aws_vpc_peering_connection_accepter" "eu_region_code" {
  for_each = { for k, v in var.vpc_peer_info : k => v if local.need_accepter[k] == true && v.vpc_peer_requester_config.requester_region_code == "eu-west-1" }

  provider = aws.eu-accepter

  vpc_peering_connection_id = aws_vpc_peering_connection.eu_region_code[each.key].id
  auto_accept               = true

  tags = merge({ Name = each.key }, { Side = "Accepter" }, try(each.value.vpc_peer_sub_tags, {}))
}


################################################################################
# VPC Peering Option
################################################################################
resource "aws_vpc_peering_connection_options" "eu_region_code_requester" {
  for_each = { for k, v in var.vpc_peer_info : k => v if local.need_accepter[k] == true && v.vpc_peer_requester_config.requester_region_code == "eu-west-1" }

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eu_region_code[each.key].id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

# eu 기준에서 배포 시, us 리전이 accepter 이므로  provider = aws.us-accepter 으로 선언
resource "aws_vpc_peering_connection_options" "eu_region_code_accepter" {
  for_each = { for k, v in var.vpc_peer_info : k => v if local.need_accepter[k] == true && v.vpc_peer_requester_config.requester_region_code == "eu-west-1" }

  provider = aws.us-accepter

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.eu_region_code[each.key].id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}