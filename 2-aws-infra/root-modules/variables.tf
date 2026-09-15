###################################### 
# 운영을 위한 기본 변수
######################################
variable "project" {
  type = string
}

variable "environment" {
  type = string

  # environment 입력을 잘못할 경우 에러 메세지를 발생
  validation {
    condition = contains(
      ["dev", "stg", "prd"],
      var.environment
    )

    error_message = "Supported environments are dev, stg, prd."
  }
}

variable "region" {
  type = string

  # regoin 입력을 잘못할 경우 에러 메세지를 발생
  validation {
    condition = contains([
      "eu-west-1",
      "us-west-2"
    ], var.region)

    error_message = "Supported regions are eu-west-1, us-west-2."
  }
}

###################################### 
# VPC
######################################
variable "vpcs" {
  description = "VPC Configurations"

  type = map(object({
    cidr = string

    nat_gateway_subnet_group = optional(string)

    public_subnet_groups = optional(map(object({
      cidrs = map(string)
    })), {})
    
    private_subnet_groups = optional(map(object({
      cidrs = map(string)
      enable_nat = optional(bool, false)
    })), {})
  }))
}