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

    # Public Subnet
    public_subnets = map(object({
      cidrs = map(string)
    }))
    
    # Private Subnet
    private_subnets = map(object({
      cidrs      = map(string)
      enable_nat = optional(bool, false)
    }))

    # NAT Gateway
    nat_gateway_subnets = optional(set(string), [])

    # route_table.csv의 추가 Route 사용 여부
    enable_additional_routes = optional(bool, false)
  }))
}