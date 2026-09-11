##################################
# S3 Bucket
##################################
resource "aws_s3_bucket" "s3" {
  bucket = var.bucket_name

  object_lock_enabled = var.s3_info.object_lock.enabled

  tags = merge(
    var.s3_info.tags,
    {
      "Name" = var.bucket_name
    }
  )
}


##################################
# Object Ownership
##################################
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.s3.id

  rule {
    object_ownership = var.s3_info.object_ownership
  }
}


##################################
# Public Access Block
##################################
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = var.s3_info.block_public_acls
  block_public_policy     = var.s3_info.block_public_policy
  ignore_public_acls      = var.s3_info.ignore_public_acls
  restrict_public_buckets = var.s3_info.restrict_public_buckets
}


##################################
# Versioning
##################################
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.s3.id

  versioning_configuration {
    status = var.s3_info.versioning ? "Enabled" : "Suspended"
  }
}


##################################
# Server Side Encryption
##################################
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_info.kms_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.s3_info.kms_arn
    }
  }
}


##################################
# Object Lock
##################################
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = var.s3_info.object_lock.enabled ? 1 : 0

  bucket = aws_s3_bucket.s3.id

  rule {
    default_retention {
      mode  = var.s3_info.object_lock.mode
      days  = var.s3_info.object_lock.retention_days
      years = var.s3_info.object_lock.retention_years
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this
  ]
}


##################################
# Server Access Logging
##################################
resource "aws_s3_bucket_logging" "this" {
  count = var.s3_info.logging.enabled ? 1 : 0

  bucket = aws_s3_bucket.s3.id

  target_bucket = var.s3_info.logging.target
  target_prefix = var.s3_info.logging.target_prefix

  dynamic "target_object_key_format" {
    for_each = var.s3_info.logging.target_object_key_format != null ? [1] : []

    content {
      dynamic "simple_prefix" {
        for_each = var.s3_info.logging.target_object_key_format == "SimplePrefix" ? [1] : []

        content {}
      }

      dynamic "partitioned_prefix" {
        for_each = var.s3_info.logging.target_object_key_format == "PartitionedPrefix" ? [1] : []

        content {
          partition_date_source = var.s3_info.logging.partitioned_prefix_type
        }
      }
    }
  }
}


##################################
# Bucket Policy
##################################
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.s3.id
  policy = var.s3_info.policy

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}