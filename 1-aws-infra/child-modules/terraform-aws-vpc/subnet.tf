######################################
# Public Subnet
######################################
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id = aws_vpc.vpc.id

  cidr_block = each.value.cidr
  availability_zone = "${var.aws_region}${each.value.az}"

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-pub-${each.value.group}-${each.value.az}"
      Type = "public"
    }
  )
}


######################################
# Private Subnet
######################################
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.vpc.id

  cidr_block = each.value.cidr
  availability_zone = "${var.aws_region}${each.value.az}"

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-pri-${each.value.group}-${each.value.az}"
      Type = "private"
    }
  )
}