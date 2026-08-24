# ============================================================
# MGMT <-> SVC
# ============================================================
resource "aws_vpc_peering_connection" "mgmt_svc" {
  vpc_id        = module.mgmt_vpc.vpc_id
  peer_vpc_id   = module.svc_vpc.vpc_id
  auto_accept   = true

  tags = {
    Name = "${var.project}-${var.environment}-${local.region_name}-mgmt-svc-pcx"
  }
}

# ============================================================
# SVC <-> DB VPC Peering
# ============================================================
resource "aws_vpc_peering_connection" "svc_db" {
  vpc_id        = module.svc_vpc.vpc_id
  peer_vpc_id   = module.db_vpc.vpc_id
  auto_accept   = true

  tags = {
    Name = "${var.project}-${var.environment}-${local.region_name}-svc-db-pcx"
  }
}