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
  type    = map(string)
  default = {}
}


######################################
# IAM Roles
######################################
variable "roles" {
  description = "IAM Role configurations"

  type = map(object({
    role_name = string

    services = list(string)

    instance_profile_enabled = optional(bool, false)
    aws_managed_policies     = optional(list(string), [])

    policies = optional(
      map(object({
        description = optional(string)

        statements = list(object({
          sid       = optional(string)
          effect    = string
          actions   = list(string)
          resources = list(string)
        }))
      })), {}
    )

    tags = optional(
      map(string), {}
    )
  }))

  default = {}
}