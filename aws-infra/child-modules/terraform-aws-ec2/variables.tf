######################################
# 공통 변수
######################################
# variable "context" {
#   description = "Common resource context"

#   type = object({
#     project     = string
#     environment = string
#     region_name = string
#     region_code = string
#     region      = string
#     naming_rule = string
#   })
# }

variable "common_tags" {
  description = "Common Tags"
  type    = map(string)
  default = {}
}


######################################
# ec2 특정 변수
######################################
variable "ipa_user" {
  description = "IPA User"
  type        = string
}

######################################
# EC2 Instances
######################################
variable "instances" {
  description = "EC2 instance configurations"

  type = map(object({
    #### EC2 ####
    ami_id        = string
    instance_type = string
    
    key_name             = optional(string)
    iam_instance_profile = optional(string)

    monitoring = optional(bool, false)

    user_data = optional(string)

    #### Network ####
    subnet_id = string

    security_group_ids   = optional(list(string), [])

    associate_public_ip_address = optional(bool, false)

    #### EIP ####
    eip = optional(object({
      enabled = optional(bool, false)
    }), {})

    #### Root Volume ####
    root_volume = object({
      volume_type = optional(string, "gp3")
      volume_size = number

      iops       = optional(number, 3000)
      throughput = optional(number, 125)

      encrypted  = optional(bool, true)
      kms_key_id = optional(string)

      delete_on_termination = optional(bool, true)
    })

    #### Additional EBS Volumes ####
    ebs_volumes = optional(map(object({
      device_name = string

      volume_type = optional(string, "gp3")
      volume_size = number

      iops        = optional(number, 3000)
      throughput  = optional(number, 125)

      encrypted   = optional(bool, true)
      kms_key_id  = optional(string)

      delete_on_termination = optional(bool, false)

      stop_instance_before_detaching = optional(bool, false)

      tags = optional(map(string), {})
    })), {})

    tags = optional(map(string), {})
  }))

  default = {}
  # validation {
  #   instance_type = arm64 아키텍처여야만 한다.
  # }
}