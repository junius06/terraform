# RSA 알고리즘을 이용해 private 키 생성
#resource "tls_private_key" "key01" {
#  algorithm = "RSA"
#  rsa_bits = 4096
#}

# private 키로 keypair 파일 생성
#resource "aws_key_pair" "company" {
#  key_name = "company"
#  public_key = tls_private_key.key01.public_key_pem
#}

# 생성한 keyfile local에 다운로드
#resource "local_file" "ec2_ssh_key01" {
#  filename = "${aws_key_pair.key01.key_name}.pem"
#  content = tls_private_key.key01.private_key_pem
#}