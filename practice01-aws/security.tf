# my ip 정보를 가져오기 위한 data 값
data "http" "myip" {
  url = "http://ifconfig.me/ip"
}

# Security Group 생성
resource "aws_security_group" "public" {
  vpc_id = aws_vpc.main.id
  name = "SG-public"
  description = "Public Security Group"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [ "${chomp(data.http.myip.body)}/32" ]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [ "10.0.0.0/16" ]
    description = "main VPC connect"
  }  

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "https any outbound"
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "jenkins any outbound"
  }

    ingress {
    from_port = 8000
    to_port = 8000
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "webapp any outbound"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "SG-public"
  }
}