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
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition = contains(
      [
        "BucketOwnerEnforced",
        "BucketOwnerPreferred",
        "ObjectWriter"
      ],
      var.object_ownership
    )
    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter"
  }
}

######################################
# Bucket Deletion
######################################
variable "force_destroy" {
  description = "Whether to allow deletion of the bucket including all objects"
  type        = bool
  default     = false
}

######################################
# Public Access 차단 설정 (ACLs)
######################################
variable "block_all_public_access" {
  description = "Whether to block all public access to the S3 bucket"
  type        = bool
  default     = true
}
variable "block_public_acls" {
  description = "Whether to block public ACLs"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether to ignore public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether to block public bucket policies"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether to restrict public bucket policies"
  type        = bool
  default     = true
}

######################################
# Versioning
######################################
variable "Versioning_enabled" {
  description = "Whether S3 bucket versioning is enabled"
  type        = bool
  default     = false
}

######################################
# Server Side Encryption
######################################
variable "encryption_type" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"

  validation {
    condition = contains(
      [
        "AES256",
        "aws:kms",
        "aws:kms:dsse"
      ],
      var.encryption_type
    )
    error_message = "encrytion_type must select one of the following: AES256, aws:kms, aws:kms:dsse"
  }
}

variable "kms_key_arn" {
  description = "KMS Key ARN used when encryption_type is aws:kms"
  type        = string
  default     = null

  validation {
    condition = (
      !contains(["aws:kms", "aws:kms:dsse"], var.encryption_type)
      || var.kms_key_arn != null
    )
    error_message = "kms_key_arn must be provided when encryption_type is aws:kms or aws:kms:dsse"
  }
}

variable "bucket_key_enabled" {
  description = "Whether to enable S3 Bucket Key when SSE-KMS encryption is used"
  type        = bool
  default     = true
}

######################################
# LifyCycle
######################################
variable "lifecycle" {
  description = "LifeCycle rules applied to the S3 Bucket"

  type = object({
    enabled = optional(bool, true)

    rules = optional(map(object({
      enabled = optional(bool, true)
      prefix  = optional(string)

      transitions = optional(object({
        enabled = optional(bool, false)

        rules = optional(list(object({
          days          = number
          storage_class = string
        })), [])
      }), {})

      expiration = optional(object({
        enabled = optional(bool, true)
        days    = optional(number, 180)
      }), {})

      noncurrent_version_expiration = optional(object({
        enabled = optional(bool, false)
        days    = optional(number, 180)
      }), {})

      abort_incomplete_multipart_upload = optional(object({
        enabled = optional(bool, true)
        days    = optional(number, 7)
      }), {})
    })), {})
  })

  default = {
    enabled = true
    rules   = {}
  }

  validation {
    condition = {
      var.Versioning_enabled ||
      alltrue([
        for rule in var.lifecycle.rules :
        !rule.noncurrent_version_expiration.enabled
      ])
    }
    error_message = "noncurrent_version_expiration cannot be enabled when versioning_enabled is false."
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