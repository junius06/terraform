# provider "aws" {
#   region = "ap-northeast-2"

#   shared_config_files = [ "~/.aws/conf" ]
#   shared_credentials_files = [ "~/.aws/creds" ]
#   profile = "myprofile"
#   # access_key = "~/.aws/access_key" #"${ secret.aws_access_key }"
#   # secret_key = "~/.aws/secret_key" #"${ secret.aws_secret_key }"

#   default_tags {
#     tags = {
#       Name = "credentials"
#     }
#   }
# }

resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "var.vpc_name"
    Environment = "var.environment"
  }
}


# Public Subnet
resource "aws_subnet" "public-subnet-01" {
  vpc_id = aws_vpc.default.id
  cidr_block = "var.public_subnet_cidr_block"

  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  # tags = {
  #   Name = "var.public_subnet_cidr_block"
  # }
}

resource "aws_subnet" "public-subnet-02" {
  vpc_id = aws_vpc.default.id
  cidr_block = "var.public_subnet_cidr_block"

  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  # tags = {
  #   Name = "var.public_subnet_cidr_block"
  # }
}

# Private Subnet
resource "aws_subnet" "private-subnet-01" {
  vpc_id = aws_vpc.default.id
  cidr_block = "var.private_subnet_cidr_block"

  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "var.private_subnet_cidr_block"
  }
}

resource "aws_subnet" "private-subnet-02" {
  vpc_id = aws_vpc.default.id
  cidr_block = "var.private_subnet_cidr_block"

  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "var.private_subnet_cidr_block"
  }
}


####### igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

####### ngw
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


# route_table 생성
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "rt_public"
  }
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "rt_private"
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

resource "aws_route_table_association" "route_table_association_2" {
  subnet_id = aws_subnet.public-subnet-02.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# Private Subnet 연결
resource "aws_route_table_association" "route_table_association_3" {
  subnet_id = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route_table_association" "route_table_association_4" {
  subnet_id = aws_subnet.private-subnet-02.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id = aws_route_table.route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}



# RSA 알고리즘을 이용해 private 키 생성
resource "tls_private_key" "key01" {
 algorithm = "RSA"
 rsa_bits = 4096
}

# private 키로 keypair 파일 생성
resource "aws_key_pair" "company" {
 key_name = "company"
 public_key = tls_private_key.key01.public_key_pem
}

# 생성한 keyfile local에 다운로드
resource "local_file" "ec2_ssh_key01" {
 filename = "${aws_key_pair.key01.key_name}.pem"
 content = tls_private_key.key01.private_key_pem
}