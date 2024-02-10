resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id

  tags = {
    Name = eip_jenkins
  }
}

resource "aws_eip" "web01" {
  instance = aws_instance.web01.id

  tags = {
    Name = eip_web01
  }
}