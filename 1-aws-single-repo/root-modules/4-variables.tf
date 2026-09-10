###################################### 
# 운영을 위한 기본 변수
######################################
variable "project" {
  type = string
}

variable "environment" {
  type = string

  # (검증) environment 입력을 잘못할 경우 에러 메세지를 발생
  validation {
    condition = contains(
      ["dev", "stg", "prd"],
      var.environment
    )

    error_message = "Supported environments are dev, stg, prd."
  }
}


variable "aws_region" {
  type = string

  # (검증) aws_regoin 입력을 잘못할 경우 에러 메세지를 발생
  validation {
    condition = contains([
      "eu-west-1",
      "us-west-2"
    ], var.aws_region)

    error_message = "Supported regions are eu-west-1, us-west-2, ap-northeast-2."
  }
}


###################################### 
# VPC
######################################
# SVC-VPC
variable "svc_vpc_cidr" {
  type = string
}

variable "svc_public_subnet_groups" {
  type = map(object({
    cidrs = map(string)
  }))

  description = "Public subnet groups for SVC-VPC"
}

variable "svc_private_subnet_groups" {
  type = map(object({
    cidrs      = map(string)
    enable_nat = bool
  }))

  description = "Private subnet groups for SVC-VPC"
}

variable "enable_vpc_flow_log" {
  type = bool
}


###################################### 
# VPC Endpoint
######################################
variable "s3_buckets" {
  description = "S3 bucket allowed through the SERVICE VPC endpoint"
  type        = list(string)
  default     = []
}

variable "ecr_repositories" {
  description = "ECR repositories allowed from SERVICE VPC"
  type        = list(string)
  default     = []
}


###################################### 
# EC2
######################################
variable "bastion_instance_type" {
  type        = string
  description = "EC2 Instance Type for EKS Bastion"
}

###################################### 
# EKS
######################################
variable "eks_version" {
  description = "EKS Version"
  type        = string
}

variable "eks_node_groups" {
  description = "EKS managed node groups"

  type = map(object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
  }))
}


###################################### 
# ACCOUNT 검증용 나중에 추가
######################################
# variable "aws_profile" {
#   type = string
# }

# variable "aws_account_id" {
#   type        = string
# }