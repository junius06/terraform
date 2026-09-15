variable "bucket_name" {
  type        = string

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "bucket_name must be between 3 and 63 characters."
  }
}

variable "s3_info" {
  type = object({
    kms_arn = optional(string, null) # aws:kms 사용 시 KMS Key ARN 입력 / 미사용 시 기본 암호화 알고리즘 SSE-S3 사용
    
    object_ownership = optional(string, "BucketOwnerEnforced")

    # Public Access Block 설정
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)

    # Object Lock 설정
    object_lock = optional(object({
      enabled         = optional(bool, false)
      mode            = optional(string, null)
      retention_days  = optional(number, null)
      retention_years = optional(number, null)
    }), {})

    # Logging 설정
    logging = optional(object({
      enabled                  = optional(bool, false)
      target                   = optional(string, null)
      target_prefix            = optional(string, null)
      target_object_key_format = optional(string, null)
      partitioned_prefix_type  = optional(string, null)
    }), {})

    # Versioning 설정
    versioning = optional(bool, false)

    # Lifecycle 설정
    lifecycle_enabled = optional(bool, true)
    lifecycle = optional(list(object({
      rule_name = optional(string, "default-retention")
      status    = optional(string, "Enabled")

      filter = optional(list(object({
        object_size_greater_than = optional(number, null)
        object_size_less_than    = optional(number, null)
        prefix                   = optional(string, null)
        tags                     = optional(map(string), {})
      })), null)

      transition = optional(list(object({
        days          = number
        storage_class = string
      })), [])

      expiration = optional(object({
        days = optional(number, 1095) # 기본값 3년(1095일) 이후 삭제
      }), {}) 

      # Versioning=true일 때 사용
      noncurrent_version_transition = optional(list(object({
        noncurrent_days = number
        storage_class   = string
      })), [])

      noncurrent_version_expiration = optional(object({
        noncurrent_days = number
      }), null)
    })), [{}])
    
    # root-module에서 생성한 json policy 문자열
    policy = string

    tags = map(string)
  })

  ################################## VALIDATION ##################################

  ##################################
  # KMS ARN
  ##################################
  validation {
    condition = (
      var.s3_info.kms_arn == null ||
      can(regex(
        "^arn:aws[a-zA-Z-]*:kms:[a-z0-9-]+:[0-9]{12}:key/.+$",
        var.s3_info.kms_arn
      ))
    )

    error_message = "kms_arn must be a valid AWS KMS Key ARN or null."
  }

  ##################################
  # Object Ownership
  ##################################
  validation {
    condition = contains(
      [
        "BucketOwnerEnforced",
        "BucketOwnerPreferred",
        "ObjectWriter"
      ],
      var.s3_info.object_ownership
    )

    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter."
  }

  ##################################
  # Object Lock Mode
  ##################################
  validation {
    condition = (
      var.s3_info.object_lock.mode == null ||
      contains(
        ["GOVERNANCE", "COMPLIANCE"],
        var.s3_info.object_lock.mode
      )
    )

    error_message = "object_lock.mode must be GOVERNANCE, COMPLIANCE, or null."
  }

  ##################################
  # Object Lock → Versioning Required
  ##################################
  validation {
    condition = (
      var.s3_info.object_lock.enabled == false ||
      var.s3_info.versioning == true
    )

    error_message = "versioning must be true when Object Lock is enabled."
  }

  ##################################
  # Object Lock Retention Mode
  ##################################
  validation {
    condition = (
      var.s3_info.object_lock.enabled == false ||
      var.s3_info.object_lock.mode != null
    )

    error_message = "object_lock.mode must be configured when Object Lock is enabled."
  }

  ##################################
  # Retention Days / Years
  # 둘 중 하나만 사용
  ##################################
  validation {
    condition = !(
      var.s3_info.object_lock.retention_days != null &&
      var.s3_info.object_lock.retention_years != null
    )

    error_message = "Only one of object_lock.retention_days or object_lock.retention_years can be configured."
  }

  ##################################
  # Object Lock Retention Period
  ##################################
  validation {
    condition = (
      var.s3_info.object_lock.enabled == false ||
      var.s3_info.object_lock.retention_days != null ||
      var.s3_info.object_lock.retention_years != null
    )

    error_message = "retention_days or retention_years must be configured when Object Lock is enabled."
  }

  ##################################
  # Retention Values
  ##################################
  validation {
    condition = (
      (var.s3_info.object_lock.retention_days == null ||
       var.s3_info.object_lock.retention_days > 0)
      &&
      (var.s3_info.object_lock.retention_years == null ||
       var.s3_info.object_lock.retention_years > 0)
    )

    error_message = "Object Lock retention_days and retention_years must be greater than 0."
  }

  ##################################
  # Logging Target
  ##################################
  validation {
    condition = (
      var.s3_info.logging.enabled == false ||
      (
        var.s3_info.logging.target != null &&
        trimspace(var.s3_info.logging.target) != ""
      )
    )

    error_message = "logging.target must be configured when logging is enabled."
  }

  ##################################
  # Logging Object Key Format
  ##################################
  validation {
    condition = (
      var.s3_info.logging.target_object_key_format == null ||
      contains(
        ["SimplePrefix", "PartitionedPrefix"],
        var.s3_info.logging.target_object_key_format
      )
    )

    error_message = "logging.target_object_key_format must be SimplePrefix, PartitionedPrefix, or null."
  }

  ##################################
  # Partitioned Prefix Type
  ##################################
  validation {
    condition = (
      var.s3_info.logging.partitioned_prefix_type == null ||
      contains(
        ["EventTime", "DeliveryTime"],
        var.s3_info.logging.partitioned_prefix_type
      )
    )

    error_message = "logging.partitioned_prefix_type must be EventTime, DeliveryTime, or null."
  }

  ##################################
  # PartitionedPrefix 사용 시 Type 필수
  ##################################
  validation {
    condition = (
      var.s3_info.logging.target_object_key_format != "PartitionedPrefix" ||
      var.s3_info.logging.partitioned_prefix_type != null
    )

    error_message = "logging.partitioned_prefix_type must be configured when target_object_key_format is PartitionedPrefix."
  }

  ##################################
  # SimplePrefix 사용 시
  # partitioned_prefix_type 금지
  ##################################
  validation {
    condition = (
      var.s3_info.logging.target_object_key_format != "SimplePrefix" ||
      var.s3_info.logging.partitioned_prefix_type == null
    )

    error_message = "logging.partitioned_prefix_type must be null when target_object_key_format is SimplePrefix."
  }

  ##################################
  # Lifecycle Enabled
  ##################################
  validation {
    condition = (
      var.s3_info.lifecycle_enabled == false ||
      length(var.s3_info.lifecycle) > 0
    )

    error_message = "At least one lifecycle rule must be configured when lifecycle_enabled is true."
  }

  ##################################
  # Lifecycle Rule Status
  ##################################
  validation {
    condition = alltrue([
      for rule in var.s3_info.lifecycle :
      contains(
        ["Enabled", "Disabled"],
        rule.status
      )
    ])

    error_message = "Lifecycle rule status must be Enabled or Disabled."
  }

  ##################################
  # Lifecycle Transition Days
  ##################################
  validation {
    condition = alltrue(flatten([
      for rule in var.s3_info.lifecycle : [
        for transition in rule.transition :
        transition.days >= 0
      ]
    ]))

    error_message = "Lifecycle transition days must be greater than or equal to 0."
  }

  ##################################
  # Lifecycle Storage Class
  ##################################
  validation {
    condition = alltrue(flatten([
      for rule in var.s3_info.lifecycle : [
        for transition in rule.transition :
        contains(
          [
            "STANDARD_IA",
            "ONEZONE_IA",
            "INTELLIGENT_TIERING",
            "GLACIER_IR",
            "GLACIER",
            "DEEP_ARCHIVE"
          ],
          transition.storage_class
        )
      ]
    ]))

    error_message = "Lifecycle transition storage_class contains an unsupported value."
  }

  ##################################
  # Lifecycle Expiration
  ##################################
  validation {
    condition = alltrue([
      for rule in var.s3_info.lifecycle :
      rule.expiration == null || rule.expiration.days > 0
    ])

    error_message = "Lifecycle expiration days must be greater than 0."
  }

  ##################################
  # Noncurrent Version Transition
  ##################################
  validation {
    condition = (
      var.s3_info.versioning == true ||
      alltrue([
        for rule in var.s3_info.lifecycle :
        length(rule.noncurrent_version_transition) == 0 &&
        rule.noncurrent_version_expiration == null
      ])
    )

    error_message = "Noncurrent version lifecycle settings can only be used when versioning is enabled."
  }

  ##################################
  # Noncurrent Version Days
  ##################################
  validation {
    condition = alltrue(flatten([
      for rule in var.s3_info.lifecycle : concat(
        [
          for transition in rule.noncurrent_version_transition :
          transition.noncurrent_days > 0
        ],
        [
          rule.noncurrent_version_expiration == null
          ? true
          : rule.noncurrent_version_expiration.noncurrent_days > 0
        ]
      )
    ]))

    error_message = "Noncurrent version lifecycle days must be greater than 0."
  }

  ##################################
  # Noncurrent Storage Class
  ##################################
  validation {
    condition = alltrue(flatten([
      for rule in var.s3_info.lifecycle : [
        for transition in rule.noncurrent_version_transition :
        contains(
          [
            "STANDARD_IA",
            "ONEZONE_IA",
            "INTELLIGENT_TIERING",
            "GLACIER_IR",
            "GLACIER",
            "DEEP_ARCHIVE"
          ],
          transition.storage_class
        )
      ]
    ]))

    error_message = "Noncurrent version transition storage_class contains an unsupported value."
  }
}
