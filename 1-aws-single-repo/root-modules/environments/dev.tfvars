project         = "project"

environment     = "dev"
aws_region      = "eu-west-1"   # aws_region 값에 따라 `locals.tf` 내에서 변수 `region_name`, `region_code` 값을 자동으로 매핑한다.

# aws_account_id  = ""

# ============================================================
# MGMT
# ============================================================
# VPC
mgmt_vpc_cidr        = "10.0.0.0/16"

mgmt_public_subnet_cidrs = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
}

# ============================================================
# SVC
# ============================================================
# VPC
svc_vpc_cidr        = "10.10.0.0/16"

eks_cluster_private_subnet_cidrs = {
  a = "10.10.0.0/25",
  b = "10.10.0.128/25"
}
svc_private_subnet_groups = {
  svc = {
    cidrs = {
      a = "10.10.1.0/24"
      b = "10.10.2.0/24"
    }
    enable_nat = false
  }

  ops = {
    cidrs = {
      a = "10.10.11.0/24"
      b = "10.10.12.0/24"
    }
    enable_nat = false
  }

  kpt = {
    cidrs = {
      a = "10.10.21.0/24"
      b = "10.10.22.0/24"
    }
    enable_nat = false
  }
}
# 나중에  인터넷 Egress 설계 방법을 결정한 후, 아래 중 하나를 선택해서 Module 확장.
# 방안 1: SVC VPC 자체 NAT Gateway
# 방안 2: 별도 Egress VPC
# 방안 3: Firewall/TGW를 통한 중앙집중식 Egress

# ============================================================
# DB
# ============================================================
# VPC
db_vpc_cidr        = "10.20.0.0/16"

db_private_subnet_cidrs = {
    a = "10.20.1.0/25"
    b = "10.20.1.128/25"
}

# ============================================================
# S3
# ============================================================
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