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

    error_message = "Supported regions are eu-west-1, us-west-2."
  }
}


###################################### 
# VPC
######################################
variable "main_vpc_cidr" {
  type = string

  validation {
    condition = can(cidrnetmask(var.main_vpc_cidr))
    
    error_message = "main_vpc_cidr must be a valid CIDR block."
  }
}

variable "main_public_subnets" {
  type = map(object({
    cidrs = map(string)
  }))

  description = "Public subnet groups for MAIN-VPC"
}

variable "main_private_subnets" {
  type = map(object({
    cidrs      = map(string)
    enable_nat = optional(bool, false)
  }))

  description = "Private subnet groups for MAIN-VPC"
}

# variable "enable_vpc_flow_log" {
#   type = bool
# }

# variable "vpc_flow_log_destination_arn" {
#   type = string
# }


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