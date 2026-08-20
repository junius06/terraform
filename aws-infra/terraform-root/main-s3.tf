# 완료
locals {
  s3s = { for file in fileset("./s3", "*.yaml") :
    trimsuffix(replace(replace(file, "{ENV}", var.ENV), "{REGION}", var.REGION), ".yaml") => yamldecode(replace(replace(
      file("./s3/${file}"),
      "{ENV}", var.ENV
      ),
      "{REGION}", var.REGION)
  ) }
}

module "s3" {
  source = "git@github.ecodesamsung.com:FMM-OPERATION/terraform-aws-global-s3.git?ref=main"

  for_each = local.s3s

  s3_info = { for k, v in local.s3s[*][each.key] : each.key => v }
} 