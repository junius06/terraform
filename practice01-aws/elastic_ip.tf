resource "aws_eip" "jenkins" {
    instance = aws_instance.jenkins.id
}

resource "aws_eip" "web01" {
    instance = aws_instance.web01
}