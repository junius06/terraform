resource "aws_vpc_endpoint" "this" {
  for_each            = var.vpce_info
  vpc_id              = var.vpce_vpc_id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = var.vpce_sg_id
  subnet_ids          = var.vpce_subnet_id
  service_name        = each.value.vpce_service
  private_dns_enabled = true
  dns_options {
    dns_record_ip_type                             = "ipv4"
    private_dns_only_for_inbound_resolver_endpoint = false
  }
  tags = each.value.vpce_tags
}