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
      "us-west-2",
      "ap-northeast-2"
    ], var.aws_region)

    error_message = "Supported regions are eu-west-1, us-west-2, ap-northeast-2."
  }
}


###################################### 
# VPC
######################################
##### MGMT-VPC
variable "mgmt_vpc_cidr" {
  type = string
}

variable "mgmt_public_subnet_cidrs" {
  type = map(string)
}

##### SVC-VPC
variable "svc_vpc_cidr" {
  type = string
}

variable "eks_cluster_private_subnet_cidrs" {
  type = map(string)
}

variable "svc_private_subnet_groups" {
  description = "Private subnet groups for SVC VPC"

  type = map(object({
    cidrs      = map(string)
    enable_nat = bool
  }))
}

##### DB-VPC
variable "db_vpc_cidr" {
  type = string
}

variable "db_private_subnet_cidrs" {
  type = map(string)
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
  description = "EC2 Instance Type for Bastion"
  type        = string
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