######################################
# VPC
######################################
variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "region_name" {
  type = string
}

variable "region_code" {
  type = string
}

variable "region_prefix" {
  type = string
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

######################################
# Public Subnet Groups
######################################
variable "public_subnet_groups" {
  type = map(object({
    cidrs = map(string)
  }))
}

######################################
# Private Subnet Groups
######################################
variable "private_subnet_groups" {
  type = map(object({
    cidrs = map(string)

    # NAT OutBound Route 사용 여부: 기본 false, root-modules/tfvars-env/{env}.tfvars 에서 핸들링
    enable_nat = optional(bool, false)
  }))
}

######################################
# Internet Gateway
######################################
variable "create_internet_gateway" {
  type    = bool
  default = false
}

######################################
# NAT Gateway
######################################
variable "create_nat_gateway" {
  type    = bool
  default = false
}

variable "nat_gateway_subnet_group" {
  type        = string
  description = "Public Subnet Group in which NAT Gateways are created."
}

######################################
# VPC Flow Log
######################################
variable "enable_vpc_flow_log" {
  type    = bool
  default = true
}

variable "vpc_flow_log_s3_name" {
  type        = string
  description = "S3 Bucket ARN for VPC Flow Logs from S3 Module Output"
}

######################################
# Tags
######################################
variable "tags" {
  type    = map(string)
  default = {}
}