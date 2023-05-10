# route_table 생성
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-01"
  }
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-01"
  }
}

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


#####################
###### Connect ######
#####################

# Public Subnet 연결
resource "aws_route_table_association" "route_table_association_1" {
  subnet_id = aws_subnet.public-subnet-01.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# Private Subnet 연결
resource "aws_route_table_association" "route_table_association_2" {
  subnet_id = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id = aws_route_table.route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}