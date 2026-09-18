locals {
  naming_rule = "${var.context.project}-${var.context.environment}-${var.context.region_name}"
}

# Public Access 차단 설정 (ACLs) 계산 로직
## block_all_public_access = true인 경우, Public Access 전체 차단 / false인 경우, Public Access 개별 핸들링
locals {
  block_public_acls       = (var.block_all_public_access ? true : var.block_public_acls)
  ignore_public_acls      = (var.block_all_public_access ? true : var.ignore_public_acls)
  block_public_policy     = (var.block_all_public_access ? true : var.block_public_policy)
  restrict_public_buckets = (var.block_all_public_access ? true : var.restrict_public_buckets)
}