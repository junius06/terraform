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

    # Internet Gateway
    create_internet_gateway = optional(bool, true)

    # NAT Gateway
    nat_gateway_subnets = optional(set(string), [])

    # route_table.csv의 추가 Route 사용 여부
    enable_additional_routes = optional(bool, false)

    # VPC Peering
    vpc_peerings = optional(map(object({
      enable = optional(bool, false)

      accepter_vpc_id = string
      accepter_region = optional(string)

      enable_cross_account = optional(bool, false)
      accepter_account_id  = optional(string)
    })), {}) # tfvars파일에서 vpcs.{vpc_name}.vpc_peering가 존재하지 않을 경우 값 없음
  }))
}

###################################### 
# EC2
######################################
variable "ec2_instances" {
  description = "EC2 instance configuration"

  type = map(object({
    # Network
    vpc_name     = string
    subnet_group = string
    zone         = string

    security_group_ids = optional(list(string), [])

    # Instance
    ami_id = string
    instance_type = string

    key_name             = optional(string)
    iam_instance_profile = optional(string)

    associate_public_ip_address = optional(bool, false)

    monitoring = optional(bool, false)

    user_data = optional(string)
  }))
}