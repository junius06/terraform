# 완료
locals {
  iam_roles = { for file in fileset("./iam/role", "*.yaml") :
    trimsuffix(replace(replace(file, "{ENV}", var.ENV), "{REGION}", var.REGION), ".yaml") => yamldecode(replace(replace(
      file("./iam/role/${file}"),
      "{ENV}", var.ENV
      ),
      "{REGION}", var.REGION)
  ) }
}


module "iam_role" {

  source = "git@github.ecodesamsung.com:FMM-OPERATION/terraform-aws-global-iam.git?ref=main"

  for_each = local.iam_roles

  iam_info = { for k, v in local.iam_roles[*][each.key] : each.key => v }
}