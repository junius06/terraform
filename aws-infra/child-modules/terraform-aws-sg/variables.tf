######################################
# 공통 변수
######################################
variable "context" {
  description = "Common resource context"

  type = object({
    project     = string
    environment = string
    region_name = string
    region      = string
    naming_rule = string
  })
}

variable "common_tags" {
  description = "Common Tags"
  type        = map(string)
  default = {}
}

######################################
# Security Groups
######################################
variable "security_groups" {
  description = "Security Groups"

  type        = map(object({
    sg_name     = string
    description = string
    vpc_id      = string
  }))

  default = {}
}

variable "rules" {
  description = "Security Group Rules"

  type        = map(object({
    security_group_key = string
    type               = string
    protocol           = string
    from_port          = number
    to_port            = number
    cidr_ipv4          = optional(string)
    description        = optional(string)
    referenced_security_group_id = optional(string)
  }))

  default = {}
}