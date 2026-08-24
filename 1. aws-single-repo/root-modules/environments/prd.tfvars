project         = "project"

environment     = "prd"
aws_region      = "eu-west-1"   # aws_region 값에 따라 `locals.tf` 내에서 변수 `region_name`, `region_code` 값을 자동으로 매핑한다.

# aws_account_id  = ""

# VPC
vpc_cidr        = "10.30.0.0/16"

public_subnet_cidrs = {
    a = "10.30.1.0/24"
    b = "10.30.2.0/24"
}

private_subnet_cidrs = {
    a = "10.30.10.0/24"
    b = "10.30.20.0/24"
}