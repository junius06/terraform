variable "route_rules" {
  type = list(object({
    dst_cidr_block = string
    id             = string
    route_table    = string
    target         = string
    target_type    = string
  }))
}

#### NAT
variable "target_nat_exist" {
  type    = list(string)
  default = null
}

variable "target_nat_info" {
  type    = any
  default = null
}

#### TGWA
variable "target_tgwa_exist" {
  type    = list(string)
  default = null
}

variable "target_tgwa_info" {
  type    = any
  default = null
}

#### GWLB
variable "target_gwlb_ep_exist" {
  type    = list(string)
  default = null
}

variable "target_gwlb_ep_info" {
  type    = any
  default = null
}

#### VPC Peer US
variable "target_vpc_peer_exist_us" {
  type    = any
  default = []
}

variable "target_vpc_peer_info_us" {
  type    = any
  default = null
}

#### VPC Peer EU
variable "target_vpc_peer_exist_eu" {
  type    = any
  default = []
}

variable "target_vpc_peer_info_eu" {
  type    = any
  default = null
}

#### Pri RTB
variable "pri_route_table_info" {
  type    = any
  default = null
}