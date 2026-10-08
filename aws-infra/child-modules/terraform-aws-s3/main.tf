######################################
# Bucket
######################################
resource "aws_s3_bucket" "this" {
  bucket = "${var.context.naming_rule}-${var.bucket_name}"
  force_destroy = var.force_destroy.enabled

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.context.naming_rule}-${var.bucket_name}",
      SEC_ASSETS_PII    = "N", # 필수 태깅
      SEC_ASSETS_PUBLIC = "N"  # 필수 태깅
    },
  )
}

######################################
# 객체 소유권 (ACL비활성화/활성화)
######################################
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership.type
  }
}

######################################
# Public Access 차단 설정 (ACLs)
######################################
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = local.public_access_block.block_public_acls
  ignore_public_acls      = local.public_access_block.ignore_public_acls
  block_public_policy     = local.public_access_block.block_public_policy
  restrict_public_buckets = local.public_access_block.restrict_public_buckets
}

######################################
# Versioning
######################################
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning.enabled ? "Enabled" : "Suspended"
  }
}

######################################
# Server Side Encryption
######################################
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption.type
      kms_master_key_id = local.kms_key_arn
    }

    bucket_key_enabled = local.bucket_key_enabled
  }
}

######################################
# LifyCycle
######################################
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = (var.lifecycle_config.enabled && length(local.lifecycle_rules) > 0) ? 1 : 0
  
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = local.lifecycle_rules

    content {
      id     = rule.key
      status = "Enabled"

      ######################################
      # Scope
      ######################################
      # All
      dynamic "filter" {
        for_each = (rule.value.scope.type == "all" ? [1] : [])

        content {}
      }

      # Filter
      dynamic "filter" {
        for_each = (rule.value.scope.type == "filter" ? [rule.value] : [])

        content {
          and {
            prefix = rule.value.scope.filter.prefix

            object_size_greater_than = (
              rule.value.scope.filter.object_min.enabled
              ? (
                  rule.value.scope.filter.object_min.value
                  * local.object_size_unit[rule.value.scope.filter.object_min.unit]
                )
              : null
            )

            object_size_less_than = (
              rule.value.scope.filter.object_max.enabled
              ? (
                  rule.value.scope.filter.object_max.value
                  * local.object_size_unit[rule.value.scope.filter.object_max.unit]
                )
              : null
            )

            tags = local.lifecycle_tags[rule.key]
          }
        }
      }

      # Current Version Transition
      dynamic "transition" {
        for_each = (
          rule.value.operations.current_version_transition.enabled
          ? rule.value.operations.current_version_transition.rules
          : []
        )

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # Noncurrent Version Transition
      dynamic "noncurrent_version_transition" {
        for_each = (
          rule.value.operations.noncurrent_version_transition.enabled
          ? rule.value.operations.noncurrent_version_transition.rules
          : []
        )

        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class

          newer_noncurrent_versions = (noncurrent_version_transition.value.newer_noncurrent_versions)
        }
      }

      # Current Version Expiration
      dynamic "expiration" {
        for_each = (
          rule.value.operations.current_version_expiration.enabled
          ? [rule.value.operations.current_version_expiration]
          : []
        )

        content {
          days = expiration.value.days
        }
      }

      # Noncurrent Version Expiration
      dynamic "noncurrent_version_expiration" {
        for_each = (
          rule.value.operations.noncurrent_version_expiration.enabled
          ? [rule.value.operations.noncurrent_version_expiration]
          : []
        )

        content {
          noncurrent_days = noncurrent_version_expiration.value.days

          newer_noncurrent_versions = (
            noncurrent_version_expiration.value.newer_noncurrent_versions
          )
        }
      }

      # Expired Object Delete Marker
      dynamic "expiration" {
        for_each = (
          rule.value.operations.cleanup.expired_object_delete_marker.enabled
          ? [1]
          : []
        )

        content {
          expired_object_delete_marker = true
        }
      }

      # Abort Incomplete Multipart Upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = (
          rule.value.operations.cleanup.abort_incomplete_multipart_upload.enabled
          ? [rule.value.operations.cleanup.abort_incomplete_multipart_upload]
          : []
        )

        content {
          days_after_initiation = (
            abort_incomplete_multipart_upload.value.days
          )
        }
      }
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this
  ]
}

######################################
# Bucket Policy
######################################
resource "aws_s3_bucket_policy" "this" {
  count = var.bucket_policy != null ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy

  depends_on = [ 
    aws_s3_bucket_public_access_block.this
  ]
}