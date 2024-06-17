variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "environment" {
  description = "The environment for the VPC"
  type        = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "The environment must be one of dev, stage, prod."
  }
}

variable "instance_type" {
  description = "The type of the instance"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the instance"
  type        = string
}