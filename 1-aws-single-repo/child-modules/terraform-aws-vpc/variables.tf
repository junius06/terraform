variable "public_subnet_cidrs" {
  type    = map(string)
  default = {}
}

variable "private_subnet_cidrs" {
  type    = map(string)
  default = {}
}

variable "eks_cluster_private_subnet_cidrs" {
  type    = map(string)
  default = {}
}

variable "eks_node_subnet_groups" {
  type = map(object({
    cidrs      = map(string)
    enable_nat = bool
  }))
  default = {}
}




# Mingyue Code
variable "region_code" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  description = "CIDR Block for the VPC"
  type        = string
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "public_subnet" {
  description = "Map of public subnets"
  type = list(object({
    subnet_cidr = string
    tags        = map(string)
  }))
}

variable "private_subnet" {
  description = "Map of private subnets"
  type = list(object({
    subnet_cidr = string
    tags        = map(string)
  }))
}

variable "vpc_flow_log_s3_name" {
  description = "VPC Flow Log S3 Bucket Name"
  type        = string
}

################################################################################
# NAT Gateway
################################################################################
variable "public_nat_gateway_subnets" {
  description = "Subnets for NAT placement"
  type        = list(string)
}