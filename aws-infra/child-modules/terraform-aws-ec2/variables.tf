######################################
# 공통 변수
######################################
variable "context" {
  description = "Common resource context"

  type = object({
    project     = string
    environment = string
    region_name = string
    region_code = string
    region      = string
  })
}

variable "common_tags" {
  description = "Common Tags"
  type    = map(string)
  default = {}
}

######################################
# Common EC2 configuration
######################################
variable "default_instance_type" {
  description = "Default EC2 instance type"
  type        = string
}

variable "default_ami_id" {
  description = "Default AMI ID"
  type        = string
}

variable "default_key_name" {
  description = "Default EC2 Key Pair name"
  type        = string
  default     = null
}

variable "default_iam_instance_profile" {
  description = "Default IAM Instance Profile name"
  type        = string
  default     = null
}

variable "default_security_group_ids" {
  description = "Default Security Group IDs"
  type        = list(string)
  default     = []
}

######################################
# EC2 Instances
######################################
variable "Instances" {
  description = "EC2 instance definitions"

  type = map(object({
    ami_id        = string
    instance_type = string
    
    key_name      = optional(string)

    # Network
    vpc_id                      = string
    subnet_id                   = string
    associate_public_ip_address = optional(bool, false)

    security_group_ids   = list(string)
    iam_instance_profile = string

    eip = optional(object({
      enabled = optional(bool, false)
    }), {})

    # Storage
    ## Root Volume
    root_volume = optional(object({
      volume_type = optional(string, "gp3")
      volume_size = optional(number, 30)
      iops = optional(number, 3000)
      throughput = optional(number, 125)
      encrypted = optional(bool, true)
      
      kms_key_id = optional(string)
      delete_on_termination = optional(bool, false)

      tags = optional(map(string), {})
    }), {})

    ## Additional EBS Volumes
    ebs_volumes = optional(map(object({
      device_name = string

      volume_type = optional(string, "gp3")
      volume_size = number
      iops        = optional(number, 3000)
      throughput  = optional(number, 125)

      encrypted   = optional(bool, true)
      kms_key_id  = optional(string)

      delete_on_termination = optional(bool, false)

      tags = optional(map(string), {})
    })), {})

    user_data = optional(string)

    monitoring = optional(bool, false)

    tags = optional(map(string), {})
  }))

  # validation {
  #   instance_type = arm64 아키텍처여야만 한다.
  # }
}