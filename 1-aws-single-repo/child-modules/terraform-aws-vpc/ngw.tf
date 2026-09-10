resource "aws_eip" "nat" {
  # root-module/vpc.tf파일에서 `var.create_nat_gateway`값이 true일 때 생성, false일 경우 미생성
  for_each = var.create_nat_gateway ? var.public_subnet_groups[var.nat_gateway_subnet_group].cidrs : {}

  domain = "vpc"

  tags = merge(
    var.tags,
    {
        Name = "${var.vpc_name}-ngw-eip-${each.key}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  for_each = var.create_nat_gateway ? var.public_subnet_groups[var.nat_gateway_subnet_group].cidrs : {}

  # 동일 AZ용 EIP 연결
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public["${var.nat_gateway_subnet_group}-${each.key}"].id

  tags = merge(
    var.tags,
    {
        Name = "${var.vpc_name}-ngw-${each.key}"
    }
  )

  # NAT Gateway가 Internet Gateway 생성/연결 이후 생성되도록 의존성 설정
  depends_on = [
    aws_internet_gateway.this
  ]
}