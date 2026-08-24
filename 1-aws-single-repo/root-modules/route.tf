# ============================================================
# MGMT -> SVC
# ============================================================
resource "aws_route" "mgmt_to_svc" {
  for_each = module.mgmt_vpc.public_route_table_ids

  route_table_id            = each.value
  destination_cidr_block    = var.svc_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt_svc.id
}


# ============================================================
# SVC -> MGMT
# ============================================================
resource "aws_route" "svc_to_mgmt" {
  for_each = module.svc_vpc.private_route_table_ids

  route_table_id            = each.value
  destination_cidr_block    = var.mgmt_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt_svc.id
}


# ============================================================
# SVC -> DB
# ============================================================
resource "aws_route" "svc_to_db" {
  for_each = module.svc_vpc.private_route_table_ids

  route_table_id            = each.value
  destination_cidr_block    = var.db_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.svc_db.id
}


# ============================================================
# DB -> SVC
# ============================================================
resource "aws_route" "db_to_svc" {
  for_each = module.db_vpc.private_route_table_ids

  route_table_id            = each.value
  destination_cidr_block    = var.svc_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.svc_db.id
}


# for_each                  : module.xxx_vpc 에 있는 public/private_route_table 들을 대상
# route_table_id            : 현재 Route를 추가할 Route Table의 ID
# destination_cidr_block    : 목적지가 되는 VPC_CIDR
# vpc_peering_connection_id : 목적지로 갈 때 사용할 Gateway (VPC Peering Name)