variable "vpc_peer_info" {
  type = map(object({
    vpc_peer_name = string
    vpc_peer_requester_config = object({
      requester_vpc     = string
      requester_account = string
      requester_region  = string
    })
    vpc_peer_accepter_config = object({
      accepter_vpc     = string
      accepter_account = string
      accepter_region  = string
    })
    vpc_peer_sub_tags = map(string)
  }))
}