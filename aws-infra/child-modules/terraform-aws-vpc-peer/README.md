```
terraform-aws-vpc
        │
        └── VPC 생성
                │
                ▼
terraform-aws-vpc-peering
        │
        └── VPC Peering Connection 생성
                │
                ▼
             pcx-id
                │
                ▼
Route Module
        │
        └── route_table.csv 기반 aws_route 생성
```