resource "aws_key_pair" "company" {
  key_name = "company"
  public_key = file("~/aws/company.pem")
}