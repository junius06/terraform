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
# EKS Cluster
######################################
variable "cluster" {
  type = map(object({
    # name                      = string
    version                   = string
    role_arn                  = string

    deletion_protection       = optional(bool, true)
    enabled_cluster_log_types = optional(
      list(string),
      [
        "api", 
        "audit", 
        "authenticator", 
        "controllerManager", 
        "scheduler"
      ]
    )

    # access_config block
    authentication_mode                         = optional(string, "API_AND_CONFIG_MAP")
    bootstrap_cluster_creator_admin_permissions = optional(bool, false)

    # vpc_config block
    subnet_ids                = list(string)
    security_group_ids        = optional(list(string), [])

    endpoint_private_access   = optional(bool, true)
    endpoint_public_access    = optional(bool, false)
    public_access_cidrs       = optional(list(string), [])

    ##############
    # Node Groups
    ##############
    node_groups = optional(map(object({
      node_role_arn   = string

      subnet_ids      = list(string)

      instance_types = optional(
        list(string), 
        ["t3.medium"]
      )
        
      ami_type      = optional(string, "AL2023_ARM_64_STANDARD")
      capacity_type = optional(string, "ON_DEMAND")

      disk_size = optional(number, 50)

      scaling = object({
        desired_size = number
        max_size     = number
        min_size     = number
      })

      max_unavailable = optional(number, 1)

      labels = optional(map(string), {})

      taints = optional(list(object({
        key    = string
        value  = optional(string)
        effect = string
      })), [])

      tags = optional(map(string), {})
    })))
    
    # Tags for the EKS cluster resource
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = length(var.cluster.subnet_ids) >= 2 && length(distinct(var.cluster.subnet_ids)) >= 2
    error_message = "Provide at least two distinct EKS cluster subnet IDs in different availability zones."
  }

  validation {
    condition = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.cluster.authentication_mode)
    error_message = "authentication_mode must be CONFIG_MAP, API, or API_AND_CONFIG_MAP."
  }

  validation {
    condition = var.cluster.endpoint_private_access || var.cluster.endpoint_public_access
    error_message = "At least one EKS API endpoint access mode must be enabled."
  }

  validation {
    condition = !var.cluster.endpoint_public_access || length(var.cluster.public_access_cidrs) > 0
    error_message = "When the public EKS API endpoint is enabled, explicitly supply public_access_cidrs."
  }
}


variable "common_tags" {
  description = "Tags shared across EKS resources."
  type        = map(string)
  default     = {}
}