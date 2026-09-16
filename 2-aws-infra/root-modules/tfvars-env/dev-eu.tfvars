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

    create_internet_gateway  = true # IGW 생성 여부
    enable_additional_routes = false # route_table.csv 적용 여부

    nat_gateway_subnets = [ # nat gateway 배치할 subnet_name 지정
      "ext"
    ]

    # Public Subnet of Main VPC
    public_subnets = {
      gw = {
        cidrs = {
          a = "10.5.0.0/27"   # 10.5.0.1 ~ 10.5.0.30  (30)
          b = "10.5.0.32/27"  # 10.5.0.33 ~ 10.5.0.62 (30)
        }
      }

      ext = {
        cidrs = {
          a = "10.5.0.64/27"    # 10.5.0.65 ~ 10.5.0.94   (30)
          b = "10.5.0.96/27"    # 10.5.0.97 ~ 10.5.0.126  (30)
        }
      }

      elb = {
        cidrs = {
          a = "10.5.0.128/26"   # 10.5.0.129 ~ 10.5.0.190 (62)
          b = "10.5.0.192/26"   # 10.5.0.193 ~ 10.5.0.254 (62)
        }
      }
    }

    # Private Subnet of Main VPC
    ## NAT를 통해 Outbound통신이 필요할 경우, enable_nat = true 설정
    private_subnets = {
      elb = {
        cidrs = {
          a = "10.5.1.0/26"    # 10.5.1.1 ~ 10.5.1.62   (62)
          b = "10.5.1.64/26"   # 10.5.1.65 ~ 10.5.1.126 (62)
        }
        enable_nat = false
      }

      cluster = {
        cidrs = {
          a = "10.5.1.128/26"   # 10.5.1.129 ~ 10.5.1.190 (62)
          b = "10.5.1.192/26"   # 10.5.3.193 ~ 10.5.3.254 (62)
        }
        enable_nat = false
      }

      fmm = {
        cidrs = {
          a = "10.5.2.0/24"     # 10.5.2.1 ~ 10.5.2.254 (254)
          b = "10.5.3.0/24"     # 10.5.3.1 ~ 10.5.3.254 (254)
        }
        enable_nat = false
      }

      kpt = {
        cidrs = {
          a = "10.5.4.0/24"     # 10.5.4.1 ~ 10.5.4.254 (254)
          b = "10.5.5.0/24"     # 10.5.5.1 ~ 10.5.5.254 (254)
        }
        enable_nat = false # outbound on/off 핸들링
      }

      obs = {
        cidrs = {
          a = "10.5.6.0/24"     # 10.5.6.1 ~ 10.5.6.254 (254)
          b = "10.5.7.0/24"     # 10.5.7.1 ~ 10.5.7.254 (254)
        }
        enable_nat = true
      }

      mgt = {
        cidrs = {
          a = "10.5.8.0/24"     # 10.5.8.1 ~ 10.5.8.255 (254)
          b = "10.5.9.0/24"     # 10.5.9.1 ~ 10.5.9.255 (254)
        }
        enable_nat = false
      }
    }
  }
}
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