module "s3" {
  source = "../child-modules/terraform-aws-s3"

  for_each = local.s3_buckets
  
  # YAML 파일명을 bucket의 논리적 이름으로 사용
  bucket_name = each.key

  object_ownership        = each.value.object_ownership
  force_destroy           = each.value.force_destroy
  block_all_public_access = each.value.block_all_public_access
  versioning              = each.value.versioning
  encryption              = each.value.encryption
  lifecycle               = each.value.lifecycle

  bucket_policy = (
    each.value.bucket_policy.enabled
    ? templatefile(
        "${path.module}/s3/bucket_policies/${coalesce(each.value.bucket_policy.name, each.key)}.json.tftpl",
        {
          bucket_arn = "arn:aws:s3:::${local.context.project}-${local.context.environment}-${local.context.region_name}-${each.key}"

          aws_account_id = data.aws_caller_identity.current.account_id
          aws_region     = local.context.region
        }
      )
    : null
  )

  context     = local.context
  common_tags = local.common_tags
}