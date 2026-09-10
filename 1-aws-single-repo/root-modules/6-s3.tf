######################################
# S3 Configuration
######################################
locals {
  ## ${path.module} : 현재 Terraform 코드가 속한 Module의 디렉터리 경로

  # 모든 환경에서 공통으로 생성할 s3/common 디렉터리 하위의 YAML 파일 조회
  s3_common_files = fileset(
    "${path.module}/s3/common",
    "*.yaml"
  )

  # 각 yaml 파일을 읽어 terraform object로 변환
  s3_common_buckets = {
    for filename in local.s3_common_files :

    trimsuffix(filename, ".yaml") => yamldecode(    # 접미사 제거 후 파일명이 bucket의 논리적 이름으로 사용
      file("${path.module}/s3/common/${filename}")
    )
  }

  # 특정 환경(dev/stg/prd)에서 생성할 s3/common 디렉터리 하위의 YAML 조회
  s3_environments_files = fileset(
    "${path.module}/s3/environments/${var.environment}",
    "*.yaml"
  )

  s3_environments_buckets = {
    for filename in local.s3_environments_files :

    trimsuffix(filename, ".yaml") => yamldecode(
      file("${path.module}/s3/environments/${var.var.environment}/${filename}")
    )
  }

  # 공통 Bucket + 현재 환경 전용 Bucket 병합
  s3_buckets = merge(
    # 뒤에서 앞에거를 덮어쓰기 해서, 뒤에 적는 것이 우선순위가 더 높다.
    local.s3_common_buckets,
    local.s3_environments_buckets
  )
}

######################################
# S3 Buckets
######################################
module "s3" {
  source = "../child-modules/terraform-aws-s3"

  for_each        = local.s3_config.buckets
  bucket_name     = "${var.project}-${var.environment}-${local.region_name}-${each.key}"  

  versioning_enabled  = each.value.versioning
  encryption_type     = each.value.encryption
  object_ownership    = each.value.object_ownership

  block_public_acls = (
    each.value.public_access_block.block_public_acls
  )

  ignore_public_acls = (
    each.value.public_access_block.ignore_public_acls
  )

  block_public_policy = (
    each.value.public_access_block.block_public_policy
  )

  restrict_public_buckets = (
    each.value.public_access_block.restrict_public_buckets
  )

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.project}-${var.environment}-${local.region_name}-${each.key}"
      Application = each.value.application
    }
  )
}