resource "aws_vpc_endpoint" "this" {
  for_each          = var.vpce_gw_info
  vpc_id            = var.vpce_gw_vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = each.value.vpce_gw_service
  route_table_ids   = var.vpce_gw_rt_id
  tags              = each.value.vpce_gw_tags
}