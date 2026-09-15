variable "context" {
  description = "Common resource context"

  type = object({
    project     = string
    environment = string
    region_name = string
    region      = string
  })
}

variable "common_tags" {
  description = "Common Tags"

  type    = map(string)
  default = {}
}


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


variable "public_subnet_groups" {
  description = "Map of public subnets"

  type = map(object({
    cidrs = map(string)
  }))
}

variable "private_subnet_groups" {
  description = "Map of private subnets"

  type = map(object({
    cidrs      = map(string)
    enable_nat = optional(bool, false)
  }))
}

variable "nat_gateway_subnet_group" {
  description = "Public Subnets for NAT placement"
  type        = map(string)
  default     = null
}


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

variable "additional_routes" {
  description = "Additional route configurations passed from root module"

  # csv파일에 정의된 컬럼
  type = list(object({
    vpc            = string
    route_table    = string
    dst_cidr_block = string
    target_type    = string
    target         = string
  }))
}

# variable "vpc_flow_log_s3_name" {
#   description = "VPC FLOW Log S3 Bucket Name"
#   type        = string
# }