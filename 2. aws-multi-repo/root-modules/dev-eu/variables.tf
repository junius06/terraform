variable "project" {
  type = string
}

###################################### 
# 구축/운영 환경
######################################
variable "environment" {
  type = string

  # (검증) environment 입력을 잘못할 경우 에러 메세지를 발생
  validation {
    condition = contains([
      "dev",
      "stg",
      "prd"
    ], var.environment)

    error_message = "Supported environments are dev, stg, prd."
  }
}


variable "aws_region" {
  type = string

  # (검증) aws_regoin 입력을 잘못할 경우 에러 메세지를 발생
  validation {
    condition = contains([
      "eu-west-1",
      "us-west-2",
      "ap-northeast-2"
    ], var.aws_region)

    error_message = "Supported regions are eu-west-1, us-west-2, ap-northeast-2."
  }
}


###################################### 
# VPC
######################################
variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = map(string)
}

variable "private_subnet_cidrs" {
  type = map(string)
}


###################################### 
# ACCOUNT 검증용 나중에 추가
######################################
variable "aws_profile" {
  type = string
}

variable "aws_account_id" {
  type        = string
}