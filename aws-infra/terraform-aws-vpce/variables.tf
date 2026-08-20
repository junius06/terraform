##########################
# VPCE
##########################
variable "vpce_info" {
  type = map(object({
    vpce_vpc     = string
    vpce_subnets = list(string)
    vpce_sg      = list(string)
    vpce_service = string
    vpce_tags    = map(string)
  }))
}

variable "vpce_vpc_id" {
  type = string
}

variable "vpce_sg_id" {
  type = list(string)
}

variable "vpce_subnet_id" {
  type = list(string)
}