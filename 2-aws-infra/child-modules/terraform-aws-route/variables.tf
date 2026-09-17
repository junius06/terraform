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

# aws_route_table 생성
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# Public RT 생성(필) + Association
variable "public_subnets" {
  description = "Public subnets created by VPC module"

  type = map(object({
    id          = string
    subnet_name = string
    zone        = string
    cidr        = string
  }))
}

# Private RT 생성(필) + Association + NAT 사용 여부
variable "private_subnets" {
  description = "Private subnets created by VPC module"

  type = map(object({
    id          = string
    subnet_name = string
    zone        = string
    cidr        = string
    enable_nat  = bool
  }))
}

# IGW 생성 여부 확인 (true/false)
variable "create_internet_gateway" {
  description = "Whether to create public routes to the Internet Gateway"
  type        = bool
  default     = true
}

# Public 0.0.0.0/0 → IGW
variable "igw_id" {
  description = "Internet Gateeway ID"

  type    = string
  default = null
}

# Private 0.0.0.0/0 → NAT
variable "nat_gateways" {
  description = "NAT Gateway information from VPC module"

  type = map(object({
    id          = string
    subnet_name = string
    zone        = string
  }))

  default = {}
}

######################################
# Additional Routes
######################################
variable "additional_routes" {
  description = "Additional route configurations"

  # csv파일에 정의된 컬럼
  type = list(object({
    id             = string
    vpc            = string
    route_table    = string
    dst_cidr_block = string
    target_type    = string
    target         = string
    description    = string
  }))

  default = []
}

######################################
# VPC Peering
######################################
variable "vpc_peering_ids" {
  description = "Map of logical VPC peering names to VPC Peering Connection IDs"
  type        = map(string)
  default     = {}
}