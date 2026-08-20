# 완료

# local.vpcs의 output 예시
# dev-fmm-ew1-vpc = {
#   yaml 파일 내용
# }

locals {
  # fileset 함수로 디렉토리 내에 yaml 파일 확장자 리스트화 ex) ["{ENV}-fmm-{REGION}-vpc.yaml", "{ENV}-fmm-{REGION}-vpc.yaml"]
  vpcs = { for file in fileset("./vpc", "*.yaml") :
    # key로 활용하기 위해 trimsuffix 함수를 통해 .yaml 접미사 제거
    # replace 함수를 이용하여 Key(VPC yaml 파일명) 값과 Value(yaml 파일 내 문자열) 값 치환
    trimsuffix(replace(replace(file, "{ENV}", var.ENV), "{REGION}", var.REGION), ".yaml") => yamldecode(replace(replace(
      file("./vpc/${file}"),
      "{ENV}", var.ENV
      ),
      "{REGION}", var.REGION)
  ) }
}

module "vpc" {
  source = "git@github.ecodesamsung.com:FMM-OPERATION/terraform-aws-global-vpc.git?ref=main"

  for_each = local.vpcs

  region               = var.provider-region
  vpc_name             = each.key
  vpc_cidr             = each.value.vpc_cidr
  enable_dns_support   = each.value.enable_dns_support
  enable_dns_hostnames = each.value.enable_dns_hostnames

  public_nat_gateway_subnets = each.value.public_nat_gateway_subnets

  public_subnet  = each.value.public_subnet
  private_subnet = each.value.private_subnet

  vpc_flow_log_s3_name = each.value.vpc_flow_log_s3_name
}