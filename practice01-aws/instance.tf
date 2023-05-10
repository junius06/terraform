# EC2 Ubuntu20.04
resource "aws_instance" "ec2-01" {
  ami = "ami-0c6e5afdd23291f73"
  subnet_id = aws_subnet.public-subnet-01.id
  instance_type = "t2.medium"
  key_name = "company"

  vpc_security_group_ids = [ 
    aws_security_group.public.id
  ]

  tags = {
    Name = "ec2"
  }
}

resource "aws_instance" "ec2-02" {
  ami = "ami-0c6e5afdd23291f73"
  subnet_id = aws_subnet.public-subnet-01.id
  instance_type = "t2.xlarge"
  key_name = "company"

  vpc_security_group_ids = [ 
    aws_security_group.public.id
  ]

  tags = {
    Name = "ec2"
  }
}