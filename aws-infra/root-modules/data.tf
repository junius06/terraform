# 다른 리소스에서 data.aws_caller_identity.current.account_id 로 사용 가능
data "aws_caller_identity" "current" {}

# ============================================================
# Amazon Linux 2023 ARM64 AMI 
# ============================================================
data "aws_ssm_parameter" "al2023_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.18-arm64"
}
# https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html

# ============================================================
# DB VPC 정보 조회
# ============================================================
# data "aws_vpc" "db" {
#   filter {
#     name   = "tag:Name"                 # Tag "Name"의 값으로 VPC 조회
#     values = ["FLSTG_EUWEST1_VPC_ID"]   # 환경마다 VPC Name 확인, 변경 필요
#   }
# }