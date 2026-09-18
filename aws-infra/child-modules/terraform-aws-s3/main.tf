######################################
# Bucket
######################################
resource "aws_s3_bucket" "this" {
  bucket = "${local.naming_rule}-${var.bucket_name}"
  force_destroy = var.force_destroy

  tags = merge(
    var.common_tags,
    {
      Name              = "${local.naming_rule}-${var.bucket_name}",
      SEC_ASSETS_PII    = "N",
      SEC_ASSETS_PUBLIC = "N"
    },
  )
}

######################################
# 객체 소유권 (ACL비활성화/활성화)
######################################
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

######################################
# Public Access 차단 설정 (ACLs)
######################################
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = local.block_public_acls
  ignore_public_acls      = local.ignore_public_acls
  block_public_policy     = local.block_public_policy
  restrict_public_buckets = local.restrict_public_buckets
}

######################################
# Versioning
######################################
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.Versioning_enabled ? "Enabled" : "Suspended"
  }
}

######################################
# Server Side Encryption
######################################
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_type
      kms_master_key_id = (
        contains(["aws:kms", "aws:kms:dsse"], var.encryption_type) ? var.bucket_key_enabled : null
      )
    }

    bucket_key_enabled = (var.encryption_type == "aws:kms" ? var.bucket_key_enabled : false)
  }
}

######################################
# LifyCycle
######################################
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.lifecycle) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = {
      for rule_name, rule_config in var.lifecycle.rules : 
      rule_name => rule_config
      if rule_config.enabled
    }

    content {
      id     = rule.key
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix = coalesce(rule.value.prefix, "")
      }

      dynamic "transition" {
        for_each = (
          try(rule.value.transitions.enabled, false) ? try(rule.value.transitions.rules, []) : []
        )

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = (rule.value.expiration_days != null ? [rule.value.expiration_days] : [])
        
        content {
          days = expiration.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = (rule.value.noncurrent_version_expiration_days != null ? [rule.value.noncurrent_version_expiration_days] : [])

        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = (rule.value.abort_incomplete_multipart_upload_days != null ? [rule.value.abort_incomplete_multipart_uploads_days] : [])

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
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