###################################### 
# 운영을 위한 기본 변수
######################################
project         = "project"
environment     = "dev"
aws_region      = "eu-west-1"   # aws_region 값에 따라 `locals.tf` 내에서 변수 `region_name`, `region_code` 값을 자동으로 매핑한다.

###################################### 
# SVC VPC
######################################
main_vpc_cidr = "10.100.0.0/19"

# Public    : 10.100.0.0/24 ~ 10.100.5.0/24
# Reserved  : 10.100.6.0/24 ~ 10.100.9.0/24
# Private   : 10.100.10.0/24 ~ 10.100.17.0/24
# Reserved  : 10.100.18.0/24 ~ 10.100.31.0/24
main_public_subnet_groups = {
  mgmt = {
    cidrs = {
      a = "10.100.0.0/24"
      b = "10.100.1.0/24"
    }
  }

  ext = {
    cidrs = {
      a = "10.100.2.0/24"
      b = "10.100.3.0/24"
    }
  }

  elb = {
    cidrs = {
      a = "10.100.4.0/24"
      b = "10.100.5.0/24"
    }
  }
}

main_private_subnet_groups = {
  cluster = {
    cidrs = {
      a = "10.100.10.0/24"
      b = "10.100.11.0/24"
    }
  }

  svc = {
    cidrs = {
      a = "10.100.12.0/24"
      b = "10.100.13.0/24"
    }
    enable_nat = false
  }

  ops = {
    cidrs = {
      a = "10.100.14.0/24"
      b = "10.100.15.0/24"
    }
    enable_nat = true # outbound on/off 핸들링
  }

  kpt = {
    cidrs = {
      a = "10.100.16.0/24"
      b = "10.100.17.0/24"
    }
    enable_nat = false
  }
}

###################################### 
# S3 Buckets
######################################
s3_buckets = [
  "my-app-bucket"
]

# ============================================================
# ECR Repository
# ============================================================
ecr_repositories = [
  "my-app1",
  "my-app2"
]

# ============================================================
# EC2
# ============================================================
bastion_instance_type = "t4g.micro"

# ============================================================
# EKS
# ============================================================
eks_version = "1.36"

eks_node_groups = {
  svc = {
    instance_types = ["m8g.medium"]
    desired_size   = 2
    min_size       = 2
    max_size       = 6
  }
  ops = {
    instance_types = ["m8g.medium"]
    desired_size   = 2
    min_size       = 2
    max_size       = 4
  }
  kpt = {
    instance_types = ["m8g.medium"]
    desired_size   = 2
    min_size       = 2
    max_size       = 4
  }
}