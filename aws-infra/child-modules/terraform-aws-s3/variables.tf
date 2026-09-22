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
  })
}

variable "common_tags" {
  description = "Common Tags"
  type    = map(string)
  default = {}
}

######################################
# Bucket
######################################
variable "bucket_name" {
  description = "Logical name of the S3 Bucket"
  type        = string
}

######################################
# 객체 소유권 (ACL비활성화/활성화)
######################################
variable "object_ownership" {
  description = "Object ownership setting for the S3 bucket"

  type = object({
    type = optional(string, "BucketOwnerEnforced")
  })

  validation {
    condition = contains(
      [
        "BucketOwnerEnforced",
        "BucketOwnerPreferred",
        "ObjectWriter"
      ],
      var.object_ownership.type
    )

    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter"
  }
}

######################################
# Bucket Deletion
######################################
variable "force_destroy" {
  description = "Whether to allow deletion of the bucket including all objects"
  
  type = object({
    enabled = optional(bool, false)
  })

  default = {}
}

######################################
# Public Access 차단 설정 (ACLs)
######################################
variable "block_all_public_access" {
  description = "S3 Public Access Block configuration"

  type = object({
    enabled = optional(bool, true)

    block_public_acls = optional(object({
      enabled = optional(bool, true)
    }), {})

    ignore_public_acls = optional(object({
      enabled = optional(bool, true)
    }), {})

    block_public_policy = optional(object({
      enabled = optional(bool, true)
    }), {})

    restrict_public_buckets = optional(object({
      enabled = optional(bool, true)
    }), {})
  })

  default = {}
}

######################################
# Versioning
######################################
variable "versioning" {
  description = "Whether S3 bucket versioning is enabled"

  type = object({
    enabled = optional(bool, false)
  })

  default = {}
}

######################################
# Server Side Encryption
######################################
variable "encryption" {
  description = "S3 server-side encryption configuration"
  
  type = object({
    type        = optional(string, "AES256")
    kms_key_arn = optional(string, null)
    bucket_key  = optional(object({
      enabled = optional(bool, true)
    }), {})
  })

  default = {}

  validation {
    condition = contains(
      [
        "AES256",
        "aws:kms",
        "aws:kms:dsse"
      ],
      var.encryption.type
    )
    
    error_message = "encryption.type must be one of: AES256, aws:kms, aws:kms:dsse."
  }

  validation {
    condition = (
      !contains(
        ["aws:kms", "aws:kms:dsse"],
        var.encryption.type
      )
      ||
      var.encryption.kms_key_arn != null
    )

    error_message = "encryption.kms_key_arn must be provided when encryption.type is aws:kms or aws:kms:dsse."
  }
}

######################################
# LifyCycle
######################################
variable "lifecycle_config" {
  description = "S3 Lifecycle configuration"

  type = object({
    enabled = optional(bool, true)

    rules = optional(map(object({
      enabled = optional(bool, true)

      scope = optional(object({
        type = optional(string, "all")

        filter = optional(object({
          prefix = optional(string, null)

          object_min = optional(object({
            enabled = optional(bool, false)
            value   = optional(number, null)
            unit    = optional(string, "KB")
          }), {})

          object_max = optional(object({
            enabled = optional(bool, false)
            value   = optional(number, null)
            unit    = optional(string, "KB")
          }), {})

          tags = optional(map(any), {})
        }), {})
      }), {})

      operations = optional(object({
        current_version_transition = optional(object({
          enabled = optional(bool, false)

          rules = optional(list(object({
            days          = optional(number, 180)
            storage_class = optional(string, "STANDARD_IA")
          })), [])
        }), {})

        noncurrent_version_transition = optional(object({
          enabled = optional(bool, false)

          rules = optional(list(object({
            days                      = optional(number, 180)
            storage_class             = optional(string, "STANDARD_IA")
            newer_noncurrent_versions = optional(number, null)
          })), [])
        }), {})

        current_version_expiration = optional(object({
          enabled = optional(bool, true)
          days    = optional(number, 180)
        }), {})

        noncurrent_version_expiration = optional(object({
          enabled                   = optional(bool, false)
          days                      = optional(number, 180)
          newer_noncurrent_versions = optional(number, null)
        }), {})

        cleanup = optional(object({
          expired_object_delete_marker = optional(object({
            enabled = optional(bool, false)
          }), {})

          abort_incomplete_multipart_upload = optional(object({
            enabled = optional(bool, false)
            days    = optional(number, null)
          }), {})
        }), {})
      }), {})
    })), {})
  })

  default = {}

  ############ 검증 ############
  validation {
    condition = alltrue([
      for rule in var.lifecycle_config.rules :
      !rule.enabled ||
      contains(
        ["all", "filter"],
        rule.scope.type
      )
    ])

    error_message = "LifeCycle Rule scope.type must be either 'all' or 'filter'."
  }

  # scope.type = filter 인 경우, 최소 하나 이상의 filter 필요
  validation {
    condition = alltrue([
      for rule in var.lifecycle_config.rules :

      !rule.enabled 
      || 
      rule.scope.type != "filter" 
      ||
      (
        rule.scope.filter.prefix != null 
        ||
        rule.scope.filter.object_min.enabled 
        ||
        rule.scope.filter.object_max.enabled 
        ||
        try(rule.scope.filter.tags.enabled, false)
      )
    ])

    error_message = "When scope.type is 'filter', at least one filter must be configured."
  }

  # Object Size Unit Validation
  validation {
    condition = alltrue([
      for rule in var.lifecycle_config.rules :

      !rule.enabled
      ||
      (
        (
          !rule.scope.filter.object_min.enabled
          ||
          contains(
            ["B", "KB", "MB", "GB"],
            rule.scope.filter.object_min.unit
          )
        )
        &&
        (
          !rule.scope.filter.object_max.enabled
          ||
          contains(
            ["B", "KB", "MB", "GB"],
            rule.scope.filter.object_max.unit
          )
        )
      )
    ])

    error_message = "Lifecycle object size unit must be one of: B, KB, MB, GB."
  }

  # Object Size Value Validation
  validation {
    condition = alltrue([
      for rule in var.lifecycle_config.rules :

      !rule.enabled
      ||
      (
        (
          !rule.scope.filter.object_min.enabled
          ||
          (
            rule.scope.filter.object_min.value != null
            &&
            rule.scope.filter.object_min.value >= 0
          )
        )
        &&
        (
          !rule.scope.filter.object_max.enabled
          ||
          (
            rule.scope.filter.object_max.value != null
            &&
            rule.scope.filter.object_max.value > 0
          )
        )
      )
    ])

      error_message = "Object size value must be provided and greater than or equal to 0 when the object size filter is enabled."
  }

  # Versioning Validation: Noncurrent 관련 작업은 Versioning 활성화 필요
  validation {
    condition = (
      !var.lifecycle_config.enabled
      ||
      var.versioning.enabled
      ||
      alltrue([
        for rule in var.lifecycle_config.rules :

        !rule.enabled
        ||
        (
          !rule.operations.noncurrent_version_transition.enabled
          &&
          !rule.operations.noncurrent_version_expiration.enabled
        )
      ])
    )

    error_message = "Noncurrent version transition or expiration cannot be enabled when versioning_enabled.enabled is false."
  }

  # Current Version Transition
  validation {
    condition = alltrue([
      for rule in var.lifecycle_config.rules :

      !rule.enabled
      ||
      !rule.operations.current_version_transition.enabled
      ||
      length(
        rule.operations.current_version_transition.rules
      ) > 0
    ])

    error_message = "At least one rule must be provided when current_version_transition is enabled."
  }

  # Noncurrent Version Transition
    validation {
    condition = alltrue([
      for rule in var.lifecycle_config.rules :

      !rule.enabled
      ||
      !rule.operations.noncurrent_version_transition.enabled
      ||
      length(
        rule.operations.noncurrent_version_transition.rules
      ) > 0
    ])

    error_message = "At least one rule must be provided when noncurrent_version_transition is enabled."
  }

  # Current Version Expiration
    validation {
    condition = alltrue([
      for rule in var.lifecycle_config.rules :

      !rule.enabled
      ||
      !rule.operations.current_version_expiration.enabled
      ||
      (
        rule.operations.current_version_expiration.days != null
        &&
        rule.operations.current_version_expiration.days > 0
      )
    ])

    error_message = "current_version_expiration.days must be greater than 0 when current version expiration is enabled."
  }

  # Noncurrent Version Expiration
    validation {
    condition = alltrue([
      for rule in var.lifecycle_config.rules :

      !rule.enabled
      ||
      !rule.operations.noncurrent_version_expiration.enabled
      ||
      (
        rule.operations.noncurrent_version_expiration.days != null
        &&
        rule.operations.noncurrent_version_expiration.days > 0
      )
    ])

    error_message = "noncurrent_version_expiration.days must be greater than 0 when noncurrent version expiration is enabled."
  }

  # Abort Incomplete Multipart Upload
    validation {
    condition = alltrue([
      for rule in var.lifecycle_config.rules :

      !rule.enabled
      ||
      !rule.operations.cleanup.abort_incomplete_multipart_upload.enabled
      ||
      (
        rule.operations.cleanup.abort_incomplete_multipart_upload.days != null
        &&
        rule.operations.cleanup.abort_incomplete_multipart_upload.days > 0
      )
    ])

    error_message = "abort_incomplete_multipart_upload.days must be greater than 0 when multipart upload cleanup is enabled."
  }
}

######################################
# Bucket Policy
######################################
variable "bucket_policy" {
  description = "JSON bucket policy applied to the S3 Bucket"
  type        = string
  default     = null
}