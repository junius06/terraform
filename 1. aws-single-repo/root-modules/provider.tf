terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }

  # backend.hcl 파일에 저장
  backend "s3" {}
}

provider "aws" {
  region  = var.aws_region

  # 접근 Account 검증용
  # allowed_account_ids = [
  #   var.aws_account_id
  # ]

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy    = "Terraform"
    }
  }
}