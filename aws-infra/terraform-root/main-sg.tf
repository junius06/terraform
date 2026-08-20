# 완료
locals {
  security_groups = { for file in fileset("./sg", "*.csv") :
    trimsuffix(replace(replace(replace(file, "{ENV}", var.ENV), "{REGION}", var.REGION), "sg", "vpc"), ".csv") => { sg_rules = csvdecode(file("./sg/${file}")) }
  }
}



module "sg" {
  source = "git@github.ecodesamsung.com:FMM-OPERATION/terraform-aws-global-sg.git?ref=main"

  for_each = local.security_groups

  # CSV SG Rule List 전달
  sg_rules = each.value.sg_rules

  # VPC ID 값 확인 과정을 통한 Depends_on
  vpc_id = module.vpc[each.key].vpc_id
}