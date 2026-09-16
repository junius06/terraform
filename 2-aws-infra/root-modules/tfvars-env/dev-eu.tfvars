###################################### 
# 운영을 위한 기본 변수
######################################
project         = "project"
environment     = "dev"
region          = "eu-west-1"   # aws_region 값에 따라 `locals.tf` 내에서 변수 `region_name`, `region_code` 값을 자동으로 매핑한다.

###################################### 
# VPC
######################################
vpcs = {
  ## MAIN VPC ##
  main = {
    cidr = "10.5.0.0/20"

    nat_gateway_subnets = [ # 아래 public_subnets 에서 nat를 배치할 subnet_name 지정
      "ext"
    ]

    enable_additional_routes = false # 자동 생성되는 기본 route table 외, 추가적인 라우팅 정의된 파일

    # Public Subnet of Main VPC
    public_subnets = {
      gw = {
        cidrs = {
          a = "10.5.0.0/27"   # 10.5.0.1 ~ 10.5.0.31  (31)
          b = "10.5.0.32/27"  # 10.5.0.33 ~ 10.5.0.63 (31)
        }
      }

      ext = {
        cidrs = {
          a = "10.5.0.64/27"    # 10.5.0.65 ~ 10.5.0.95   (31)
          b = "10.5.0.96/27"    # 10.5.0.97 ~ 10.5.0.127  (31)
        }
      }

      elb = {
        cidrs = {
          a = "10.5.0.128/26"   # 10.5.0.129 ~ 10.5.0.191 (63)
          b = "10.5.0.192/27"   # 10.5.0.193 ~ 10.5.0.255 (63)
        }
      }
    }

    # Private Subnet of Main VPC
    ## NAT를 통해 Outbound통신이 필요할 경우, enable_nat = true 설정
    private_subnets = {
      elb = {
        cidrs = {
          a = "10.5.1.0/25"
          b = "10.5.1.128/25"
        }
        enable_nat = false
      }

      cluster = {
        cidrs = {
          a = "10.5.1.0/25"     # 10.5.1.1 ~ 10.5.1.127   (63)
          b = "10.5.1.128/25"   # 10.5.1.129 ~ 10.5.1.255 (63)
        }
        enable_nat = false
      }

      fmm = {
        cidrs = {
          a = "10.5.2.0/24"     # 10.5.2.1 ~ 10.5.2.255 (255)
          b = "10.5.3.0/24"     # 10.5.3.1 ~ 10.5.3.255 (255)
        }
        enable_nat = false
      }

      kpt = {
        cidrs = {
          a = "10.5.4.0/24"     # 10.5.4.1 ~ 10.5.4.255 (255)
          b = "10.5.5.0/24"     # 10.5.5.1 ~ 10.5.5.255 (255)
        }
        enable_nat = false # outbound on/off 핸들링
      }

      obs = {
        cidrs = {
          a = "10.5.6.0/24"     # 10.5.6.1 ~ 10.5.6.255 (255)
          b = "10.5.7.0/24"     # 10.5.7.1 ~ 10.5.7.255 (255)
        }
        enable_nat = true
      }

      mgt = {
        cidrs = {
          a = "10.5.8.0/24"     # 10.5.8.1 ~ 10.5.8.255 (255)
          b = "10.5.9.0/24"     # 10.5.9.1 ~ 10.5.9.255 (255)
        }
        enable_nat = false
      }
    }
  }
}

###################################### 
# ROUTE TABLE
######################################




###################################### 
# S3 Buckets
######################################
# s3_buckets = [
#   "my-app-bucket"
# ]

# ============================================================
# ECR Repository
# ============================================================
# ecr_repositories = [
#   "my-app1",
#   "my-app2"
# ]

# ============================================================
# EC2
# ============================================================
# bastion_instance_type = "t4g.micro"

# ============================================================
# EKS
# ============================================================
# eks_version = "1.36"

# eks_node_groups = {
#   svc = {
#     instance_types = ["m8g.medium"]
#     desired_size   = 2
#     min_size       = 2
#     max_size       = 6
#   }
#   ops = {
#     instance_types = ["m8g.medium"]
#     desired_size   = 2
#     min_size       = 2
#     max_size       = 4
#   }
#   kpt = {
#     instance_types = ["m8g.medium"]
#     desired_size   = 2
#     min_size       = 2
#     max_size       = 4
#   }
# }