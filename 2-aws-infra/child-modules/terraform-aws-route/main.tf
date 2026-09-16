###################################### 
# ROUTE TABLE
######################################
# Public Subnet은 AZ당 하나의 Route Table을 생성하지 않고 한 Group(a/b)당 하나의 Route Table을 생성한다.
resource "aws_route_table" "public" {
  # ROOT VPC 에서 IGW 생성 여부가 true일 때에만 Public RT 생성
  for_each = var.create_internet_gateway ? local.public_route_table_groups : toset([])

  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.context.project}-${var.context.environment}-${var.context.region_name}-${each.key}-pub-rt"
    }
  )
}

# Private Subnet은 AZ당 하나의 Route Table을 생성한다.
resource "aws_route_table" "private" {
  for_each = var.private_subnets

  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.context.project}-${var.context.environment}-${var.context.region_name}-${each.value.subnet_name}-pri-${each.value.zone}-rt"
    }
  )
}



###################################### 
# ROUTE
######################################
# Route Table 생성시 기본 라우팅: VPC → local 이므로 이에 대해선 별도로 설정할 필요가 없다.
# PUBLIC ROUTE → IGW
resource "aws_route" "public_igw" {
  for_each = aws_route_table.public

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

# PRIVATE ROUTE → NAT (enable_nat=true인 경우만 실행)
resource "aws_route" "private_nat" {
  for_each = local.nat_enabled_private_subnets

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  # 현재 Private Subnet과 동일한 AZ에 있는 NAT Gateway ID 검색: NAT가 하나도 없어서 [0] 접근이 실패할 경우, 오류 대신 null 사용
  nat_gateway_id = try(
    local.nat_by_private_subnet[each.key][0].id,
    null
  )

  # 현재 Private Subnet과 동일한 AZ에 있는 NAT Gateway 갯수가 1개인지 검사
  lifecycle {
    precondition {
      condition = length(
        local.nat_by_private_subnet[each.key]
      ) == 1

      error_message = "Two or more NAT Gateways exist in AZ '${each.value.zone}' for subnet '${each.key}'."
    }
  }
}


###################################### 
# ASSOCIATION
######################################
# PUBLIC
resource "aws_route_table_association" "public" {
  for_each = var.create_internet_gateway ? var.public_subnets : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.value.subnet_name].id
}

# PRIVATE
resource "aws_route_table_association" "private" {
  for_each = var.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}