# EC2 Ubuntu 20.04 64비트(x86) 2ea

resource "aws_instance" "jenkins" {
  ami = "${data.aws_ami.ubuntu20.04.id}"
  instance_type = "t2.xlarge"
  subnet_id = aws_subnet.public-subnet-01
  key_name = "company"
  vpc_security_group_ids = [ 
    aws_security_group.public.id
  ]
  user_data = <<EOF
  #! /bin/bash
  sudo hostnamectl set-hostname jenkins
  curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  sudo apt-get -y update
  sudo apt-get -y install fontconfig openjdk-11-jre
  sudo apt-get -y install jenkins
  exit
  EOF

  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "web01" {
  ami = "${data.aws_ami.ubuntu20.04.id}"
  instance_type = "t2.medium"
  subnet_id = aws_subnet.public-subnet-01
  key_name = "company"
  vpc_security_group_ids = [ 
    aws_security_group.public.id
  ]
  user_data = <<EOF
  #! /bin/bash
  sudo hostnamectl set-hostname web01
  EOF

  tags = {
    Name = "web01"
  }
}