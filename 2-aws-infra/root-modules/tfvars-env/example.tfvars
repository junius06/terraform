###################################### 
# 운영을 위한 기본 변수
######################################
project         = "project"    # Project Name
environment     = "dev"        # dev/stf/prd
region          = "eu-west-1"  # eu-west-1, us-west-2, ap-southeast-1

###################################### 
# VPC
######################################
vpcs = {
  vpc_name_01 = {                    # VPC Name
    cidr = "10.5.0.0/20"             # VPC CIDR

    create_internet_gateway  = true  # true/false, IGW 생성 여부
    enable_additional_routes = false # true/false, route_table.csv 적용 여부

    nat_gateway_subnets = [          # NAT Gateway 배치 Subnet Name, Public Subnet에 있는 Name들 중 입력.
      "public_01",
      "public_02"
    ]

    # Public Subnet of VPC
    public_subnets = {
      public_01 = {                  # Public Subnet Name
        cidrs = {
          a = "10.5.0.0/27"          # zone(a/b/c/d) = subnet cidr
          b = "10.5.0.32/27"
        }
      }

      public_02 = {
        cidrs = {
          a = "10.5.0.64/27"
          b = "10.5.0.96/27"
        }
      }
    }

    # Private Subnet of VPC
    private_subnets = {
      private_01 = {
        cidrs = {
          a = "10.5.1.0/26"
          b = "10.5.1.64/26"
        }
        enable_nat = false            # true/false, Outbound 사용 여부
      }

      private_02 = {
        cidrs = {
          a = "10.5.1.128/26"
          b = "10.5.1.192/26"
        }
        enable_nat = false
      }
    }

    vpc_peerings = {
      legacy = {                              # Peering 대상 VPC Alias 입력
        enable = true                         # true/false, VPC Peering 생성 여부

        accepter_vpc_id    = "vpc-111111111"  # Peering 대상 VPC ID 입력
        accepter_region    = null             # Peering 대상 VPC Region (null = 요청 VPC와 동일 Region 사용)

        enable_cross_account = false          # true/false, Cross Account 사용 여부
        accepter_account_id  = null           # true/false, enable_cross_account = true인 경우 입력
      }
    }
  }
}