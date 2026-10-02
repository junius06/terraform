variable "naming_rule" {
  type        = string
}

variable "common_tags" {
  description = "Common Tags"
  type        = map(string)
  default = {}
}

variable "security_groups" {
  description = "Security Groups"

  type        = map(object({
    name        = string
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