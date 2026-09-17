resource "aws_vpc_peering_connection" "this" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id

  # Cross Account
  peer_owner_id = var.enable_cross_account ? var.accepter_account_id : null

  # Cross Region
  peer_region   = local.cross_region ? local.accepter_region : null

  # Same Account + Same Region인 경우에만 자동 승인
  auto_accept = (
    !var.enable_cross_account && 
    !local.cross_region
  )

  tags = merge(
    var.common_tags,
    {
      Name = "${local.naming_rule}-${var.requester_vpc_alias}-from-${var.accepter_vpc_alias}-pcx"
    }
  )

  lifecycle {
    precondition {
      condition = (
        !var.enable_cross_account ||
        var.accepter_account_id != null
      )

      error_message = "accepter_account_id must be provided when enable_cross_account is true"
    }
  }
}

# VPC Peering을 통해 상대 VPC의 Private DNS Hostname을 해석해야 하는 경우 사용
resource "aws_vpc_peering_connection_options" "this" {
  count = (
    !var.enable_cross_account &&
    !local.cross_region
    ? 0 : 1 
  ) # cross_region=true -> 0: 리소스 생성X, false -> 1: 리소스 생성

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  requester {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }

  accepter {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }
}