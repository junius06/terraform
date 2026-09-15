resource "aws_internet_gateway" "igw" {
  # root-module의 vpc.tf파일에서 `create_internet_gateway`가 true면 IGW생성, false면 미생성
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}