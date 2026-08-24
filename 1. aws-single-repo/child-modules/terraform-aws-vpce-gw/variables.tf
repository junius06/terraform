##########################
# VPCE Gateway
##########################
variable "vpce_gw_info" {
  type = map(object({
    vpce_gw_vpc            = string
    vpce_gw_routing_tables = list(string)
    vpce_gw_service        = string
    vpce_gw_tags           = map(string)
  }))
}

variable "vpce_gw_vpc_id" {
  type = string
}

variable "vpce_gw_rt_id" {
  type = list(string)
}