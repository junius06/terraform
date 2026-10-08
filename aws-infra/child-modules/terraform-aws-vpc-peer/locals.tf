locals {
  accepter_region = coalesce(
    var.accepter_region,
    var.context.region
  )

  cross_region = (
    local.accepter_region != var.context.region
  )
  # local.accepter_region != var.context.region -> cross_region = true
  # local.accepter_region = var.context.region  -> cross_region = false
  ## 즉, root-modules에서 region값과 accepter_region의 값이 불일치할 경우 cross_region=true가 되어 활성화된다.
}