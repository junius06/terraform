module "iam_roles" {
  source = "./iam/roles"

  project      = var.project
  environment  = var.environment
  region_name  = local.region_name
}

locals {
  # 모든 환경에서 공통으로 생성할 iam/common 디렉터리 하위의 YAML 파일 조회
  iam_common_files = fileset(
    "${path.module}/iam/common",
    "*.yaml"
  )

  iam_common_roles = {
    for filename in local.iam_common_files :
    trimsuffix(filename, ".yaml") => yamldecode(
      file("${path.module}/iam/common/${filename}")
    )
  }

  # 특정 환경(dev/stg/prd)에서 생성할 iam/common 디렉터리 하위의 YAML 조회
  iam_environment_files = fileset(
    "${path.module}/iam/environments/${var.environment}",
    "*.yaml"
  )

  iam_environment_roles = {
    for filename in local.iam_environment_files :
    trimsuffix(filename, ".yaml") => yamldecode(
      file("${path.module}/iam/environments/${var.environment}/${filename}")
    )
  }

  # 공통 IAM + 특정 환경 전용 IAM 병합
  application_iam_roles = merge(
    local.iam_common_roles,
    local.iam_environment_roles
  )
}

module "application_iam_role" {
  source = "../child-modules/terraform-aws-iam-role"

  for_each = local.application_iam_roles

  role_name = "${var.project}-${var.environment}-${local.region_name}-${each.value.role_name_suffix}"

  trusted_service = each.value.trusted_service
  trusted_actions = each.value.trusted_actions

  managed_policy_arns = []

  create_instance_profile = false
}