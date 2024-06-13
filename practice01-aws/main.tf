provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "var.vpc_name" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "vpc-${var.vpc_tags}"
  }
}