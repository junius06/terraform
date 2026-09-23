locals {
  naming_rule = "${var.context.project}-${var.context.environment}-${var.context.region_name}"
}

locals {
  instances = {
    for name, instance in var.instances :

    name => {
      name = "${local.local.naming_rule}-${name}"
    }
  }
}