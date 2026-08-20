terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
  backend "s3" {
    bucket       = "dev-fmm-ew1-s3-terraform" # AWS 콘솔 수동 생성
    key          = "terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}

# TFE 사용 시, 아래 주석 해제 및 assume_role 사용 필요
provider "aws" {
  region = var.provider-region
}

# VPC Peer 용도
provider "aws" {
  region = "us-west-2"
  alias  = "us-accepter"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu-accepter"
}