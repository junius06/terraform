# bastion EC2
resource "aws_instance" "bastion" {
  ami = "ami-0a306845f8cfbd41a"
  subnet_id = aws_subnet.public_subnet.id
  instance_type = "t2.micro"
  key_name = "bastion"

  vpc_security_group_ids = [ 
    aws_security_group.sg_public.id
  ]

  tags = {
    Name = "ec2-bastion"
  }
}