######################################
# Security Groups
######################################
resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = "${var.context.naming_rule}-${each.value.sg_name}-sg"
  description = each.value.description
  vpc_id      = each.value.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.context.naming_rule}-${each.value.sg_name}-sg"
    }
  )
}

######################################
# Ingress
######################################
resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for key, rule in var.rules :
    key => rule
    if rule.type == "ingress"
  }

  security_group_id = aws_security_group.this[
    each.value.security_group_key
  ].id

  ip_protocol = each.value.protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port

  cidr_ipv4 = each.value.cidr_ipv4

  referenced_security_group_id = (
    each.value.referenced_security_group_id
  )

  description = each.value.description
}

######################################
# Egress
######################################
resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = {
    for key, rule in var.rules :
    key => rule
    if rule.type == "egress"
  }

  security_group_id = aws_security_group.this[
    each.value.security_group_key
  ].id

  ip_protocol = each.value.protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port

  cidr_ipv4 = each.value.cidr_ipv4

  referenced_security_group_id = (
    each.value.referenced_security_group_id
  )

  description = each.value.description
}