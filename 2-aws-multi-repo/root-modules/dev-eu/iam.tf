# 완료
locals {
  iam_roles = { for file in fileset("./iam/role", "*.yaml") :
    trimsuffix(replace(replace(file, "{environment}", var.environment), "{region_code}", var.region_code), ".yaml") => yamldecode(replace(replace(
      file("./iam/role/${file}"),
      "{environment}", var.environment
      ),
      "{region_code}", var.region_code)
  ) }
}


module "iam_role" {

  source = "git@github.ecodesamsung.com:OPERATION/terraform-aws-global-iam.git?ref=main"

  for_each = local.iam_roles

  iam_info = { for k, v in local.iam_roles[*][each.key] : each.key => v }
}