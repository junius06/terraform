locals {
  # block_all_public_access.enabled = true
  # → 모든 Public Access Block 설정을 true로 강제
  #
  # block_all_public_access.enabled = false
  # → 각 개별 설정값 사용
  public_access_block = {
    block_public_acls = (
      var.block_all_public_access.enabled
      ? true
      : var.block_all_public_access.block_public_acls.enabled
    )

    ignore_public_acls = (
      var.block_all_public_access.enabled
      ? true
      : var.block_all_public_access.ignore_public_acls.enabled
    )

    block_public_policy = (
      var.block_all_public_access.enabled
      ? true
      : var.block_all_public_access.block_public_policy.enabled
    )

    restrict_public_buckets = (
      var.block_all_public_access.enabled
      ? true
      : var.block_all_public_access.restrict_public_buckets.enabled
    )
  }

  # KMS Key ARN
  # - AES256       : null
  # - aws:kms      : kms_key_arn
  # - aws:kms:dsse : kms_key_arn
  kms_key_arn = (
    contains(
      ["aws:kms", "aws:kms:dsse"],
      var.encryption.type
    )
    ? var.encryption.kms_key_arn
    : null
  )

  # S3 Bucket Key
  # aws:kms에서만 적용
  bucket_key_enabled = (
    var.encryption.type == "aws:kms"
    ? var.encryption.bucket_key.enabled
    : false
  )

  # lifecycle.enabled = false
  # → 모든 Lifecycle Rule 미생성
  #
  # lifecycle.enabled = true
  # → rules[*].enabled = true인 Rule만 추출
  lifecycle_rules = (
    var.lifecycle_config.enabled
    ? {
        for rule_name, rule in var.lifecycle_config.rules :
        rule_name => rule
        if rule.enabled
      }
    : {}
  )

  # enabled는 Terraform 제어용 값이므로 실제 S3 Lifecycle Filter Tag에서는 제거
  lifecycle_tags = {
    for rule_name, rule in local.lifecycle_rules :

    rule_name => (
      rule.scope.type == "filter"
      && try(rule.scope.filter.tags.enabled, false)
      ? {
          for key, value in rule.scope.filter.tags :
          key => tostring(value)
          if key != "enabled"
        }
      : {}
    )
  }
}

locals {
  object_size_unit = {
    B  = 1
    KB = 1024
    MB = 1024 * 1024
    GB = 1024 * 1024 * 1024
  }
}