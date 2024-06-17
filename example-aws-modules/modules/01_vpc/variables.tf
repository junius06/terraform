# Environment Tags
variable "environment" {
  description = "Enter tags for the VPC"
  type = map(string)
  default = {}
}


# VPC
variable "vpc_name" {
  description = "Enter the name of the VPC"
  type = string
  default = true
}

variable "vpc_cidr_block" {
  description = "Enter the CIDR block for the VPC"
  type = string
}


# SUBNET
variable "public_subnet_cidr_block" {
  description = "Enter the name of the subnet"
  type = string
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr_block" {
  description = "Enter the name of the subnet"
  type = string
  default = "10.0.0.10/24"
  # ipv4 vpc cidr
  # subnet cicd
  # tag
}

# ROUTE TABLE
variable "rt_name" {
  description = "Enter the name of the routing tables"
  type = string
  # 라우팅 테이블에 어떤 서브넷을 명시할건지 선택
}

# INTERNET GATEWAY
variable "igw_name" {
  description = "Enter the name of the Internet Gateway"
  type = string
  # 어느 VPC에 attach할건지 선택
  # 어느 서브넷에 넣을건지 선택
}

# NAT GATEWAY
variable "ngw_name" {
  description = "Enter the name of the Nat Gateway"
  type = string
  # 유형 - 퍼블릭, 프이빗 선택
  # 어느 서넷에 넣을건지 선택
}

# INSTANCE
variable "image_id" {
  type = string
  default = "The id of the machine image (AMI) to use for the server."

  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "availability_zone_names" {
  type = list(string)
  default = [ "ap-northeast-2" ]
}

variable "ami_id_maps" {
  type = map
  default = {}
}