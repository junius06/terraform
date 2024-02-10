# Public Subnet
resource "aws_subnet" "public-subnet-01" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-01"
  }
}

resource "aws_subnet" "public-subnet-02" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-02"
  }
}

# Private Subnet
resource "aws_subnet" "private-subnet-01" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"

  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-01"
  }
}

resource "aws_subnet" "private-subnet-02" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.11.0/24"

  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-02"
  }
}