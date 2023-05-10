# NAT를 위한 EIP 생성
resource "aws_eip" "nat" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

# NAT 생성
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id

  # public subnet 연결
  subnet_id = aws_subnet.public-subnet-01.id

  tags = {
    Name = "nat"
  }
}