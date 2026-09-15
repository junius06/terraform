# 다른 리소스에서 data.aws_caller_identity.current.account_id 로 사용 가능
data "aws_caller_identity" "current" {}

# ============================================================
# Amazon Linux 2023 ARM64 AMI 
# ============================================================
# data "aws_ami" "amazon_linux_2023_arm64" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name = "name"

#     # 커널 버전 상관없이 AWS가 현재 제공하는 최신 AL2023 ARM64 : 특정 커널 버전 사용시 아래의 값 수정
#     values = [
#       "al2023-ami-2023.*-kernel-*-arm64"
#     ]
#   }

#   filter {
#     name = "architecture"
#     values = ["arm64"]
#   }

#   filter {
#     name = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name = "state"
#     values = ["available"]
#   }
# }

# ============================================================
# DB VPC 정보 조회
# ============================================================
# data "aws_vpc" "db" {
#   filter {
#     name   = "tag:Name"                 # Tag "Name"의 값으로 VPC 조회
#     values = ["FLSTG_EUWEST1_VPC_ID"]   # 환경마다 VPC Name 확인, 변경 필요
#   }
# }