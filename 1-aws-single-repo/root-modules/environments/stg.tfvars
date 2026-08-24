project         = "project"

environment     = "stg"
aws_region      = "eu-west-1"   # aws_region 값에 따라 `locals.tf` 내에서 변수 `region_name`, `region_code` 값을 자동으로 매핑한다.

# aws_account_id  = ""

# VPC
vpc_cidr        = "10.20.0.0/16"

public_subnet_cidrs = {
    a = "10.20.1.0/24"
    b = "10.20.2.0/24"
}

private_subnet_cidrs = {
    a = "10.20.10.0/24"
    b = "10.20.20.0/24"
}