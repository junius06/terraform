# VPC
variable "vpc_name" {
  description = "The name of the VPC"
  type = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type = string
}

variable "vpc_tags" {
  description = "Tags for the VPC"
  type = map(string)
  default = {}
}

# SUBNET

# ROUTE TABLE

# INTERNET GATEWAY

# NAT GATEWAY

# INSTANCE
variable "image_id" {
  type = string
}

variable "availability_zone_names" {
  type = list(string)
  default = [ "ap-northeast-2" ]
}

variable "ami_id_maps" {
  type = map
  default = {}
}