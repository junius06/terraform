######################################
# 공통 변수
######################################
variable "context" {
  description = "Common resource context"

  type = object({
    project     = string
    environment = string
    region_name = string
    region      = string
    naming_rule = string
  })
}

variable "common_tags" {
  description = "Common Tags"
  type        = map(string)
  default     = {}
}

######################################
# VPC
######################################
variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR Block for the VPC"
  type = string

  validation {
    condition = can(cidrnetmask(var.vpc_cidr))
    
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

######################################
# Subnet
######################################
variable "public_subnets" {
  description = "Map of public subnets"

  type = map(object({
    cidrs = map(string)
  }))
}

variable "private_subnets" {
  description = "Map of private subnets"

  type = map(object({
    cidrs      = map(string)
    enable_nat = optional(bool, false)
  }))
}

variable "nat_gateway_subnets" {
  description = "Public Subnets for NAT placement"
  type        = set(string)

  # tfvars에서 nat_gateway_subnets에 지정한 이름이 실제 public_subnets에 존재하는지 검증
  validation {
    condition = alltrue([
      for subnet_name in var.nat_gateway_subnets :
      contains(keys(var.public_subnets), subnet_name)
    ])

    error_message = "All nat_gateway_subnets must exist in public_subnets."
  }
}

######################################
# Settings
######################################
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type      = bool
  default   = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type      = bool
  default   = true
}

variable "vpc_peering_ids" {
  description = "Map of logical VPC peering names to VPC Peering Connection IDs"
  type        = map(string)
  default     = {}
}

######################################
# VPC FLOW LOG
######################################
variable "flow_log_destination_arn" {
  description = "S3 Bucket ARN for VPC Flow Logs"
  type        = string
}