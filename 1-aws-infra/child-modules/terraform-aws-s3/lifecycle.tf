resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.s3_info.lifecycle_enabled ? 1 : 0

  bucket = aws_s3_bucket.s3.id

  dynamic "rule" {
    for_each = var.s3_info.lifecycle

    content {
      id     = rule.value.rule_name
      status = rule.value.status

      ##################################
      # Filter
      ##################################
      dynamic "filter" {
        for_each = rule.value.filter == null ? [] : [rule.value.filter]

        content {
          dynamic "and" {
            for_each = (
              (
                rule.value.filter.prefix != null ? 1 : 0
              ) +
              (
                length(rule.value.filter.tags) > 0 ? 1 : 0
              ) +
              (
                rule.value.filter.object_size_greater_than != null ? 1 : 0
              ) +
              (
                rule.value.filter.object_size_less_than != null ? 1 : 0
              )
            ) > 1 ? [1] : []

            content {
              prefix                   = rule.value.filter.prefix
              tags                     = length(rule.value.filter.tags) > 0 ? rule.value.filter.tags : null
              object_size_greater_than = rule.value.filter.object_size_greater_than
              object_size_less_than    = rule.value.filter.object_size_less_than
            }
          }

          prefix = (
            rule.value.filter.prefix != null &&
            length(rule.value.filter.tags) == 0 &&
            rule.value.filter.object_size_greater_than == null &&
            rule.value.filter.object_size_less_than == null
          ) ? rule.value.filter.prefix : null

          object_size_greater_than = (
            rule.value.filter.object_size_greater_than != null &&
            rule.value.filter.prefix == null &&
            length(rule.value.filter.tags) == 0 &&
            rule.value.filter.object_size_less_than == null
          ) ? rule.value.filter.object_size_greater_than : null

          object_size_less_than = (
            rule.value.filter.object_size_less_than != null &&
            rule.value.filter.prefix == null &&
            length(rule.value.filter.tags) == 0 &&
            rule.value.filter.object_size_greater_than == null
          ) ? rule.value.filter.object_size_less_than : null

          dynamic "tag" {
            for_each = (
              length(rule.value.filter.tags) == 1 &&
              rule.value.filter.prefix == null &&
              rule.value.filter.object_size_greater_than == null &&
              rule.value.filter.object_size_less_than == null
            ) ? rule.value.filter.tags : {}

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }


      ##################################
      # 전체 객체 대상
      ##################################
      dynamic "filter" {
        for_each = rule.value.filter == null ? [1] : []

        content {}
      }


      ##################################
      # Transition
      ##################################
      dynamic "transition" {
        for_each = rule.value.transition

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }


      ##################################
      # Expiration
      ##################################
      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []

        content {
          days = expiration.value.days
        }
      }


      ##################################
      # Noncurrent Version Transition
      ##################################
      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition

        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }


      ##################################
      # Noncurrent Version Expiration
      ##################################
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []

        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this
  ]
}