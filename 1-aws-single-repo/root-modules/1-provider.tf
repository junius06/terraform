terraform {
  required_version = ">= 1.9.0" # 구성 실행에 허용되는 terraform CLI 버전 지정: 1.9.0 이상

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.64.0"
    }
  }

  backend "s3" {} # backend.hcl 파일에 저장
}

provider "aws" {
  # 접근 Account 검증용
  # allowed_account_ids = [
  #   var.aws_account_id
  # ]

  region  = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}