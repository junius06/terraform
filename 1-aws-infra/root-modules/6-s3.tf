locals {
  s3_common = csvdecode(
    file("${path.module}/s3/common/buckets.csv")
  )

  s3_environment = fileexists("${path.module}/s3/environments/${var.environment}-${local.region_prefix}.csv") ? csvdecode(
    file("${path.module}/s3/environments/${var.environment}-${local.region_prefix}.csv")
  ) : []

  s3_buckets = concat(
    local.s3_common,
    local.s3_environment
  )

  s3_bucket_map = {
    for bucket in local.s3_buckets :
    bucket.name => bucket
  }

  s3_bucket_names = {
    for key, bucket in local.s3_bucket_map :
    key => "${var.project}-${var.environment}-${local.region_name}-${key}"
  }
}

module "s3" {
  for_each = local.s3_bucket_map

  source = "../child-modules/terraform-aws-s3"

  bucket_name = local.s3_bucket_names[each.key]

  s3_info = {
    policy = templatefile(
      "${path.module}/s3/common/policies/${each.value.policy_file}",
      {
        bucket_arn     = "arn:aws:s3:::${local.s3_bucket_names[each.key]}"
        aws_account_id = data.aws_caller_identity.current.account_id
        aws_region     = var.aws_region
      }
    )

    tags = merge(
      local.common_tags,
      {
        Name    = local.s3_bucket_names[each.key]
        Purpose = each.value.purpose
      }
    )
  }
}