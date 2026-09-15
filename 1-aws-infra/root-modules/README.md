# Terraform Enterprise

```
# DEV
terraform init \
  -reconfigure \
  -backend-config=backends/dev.hcl
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars

# STG
terraform init \
  -reconfigure \
  -backend-config=backends/stg.hcl
terraform plan -var-file=environments/stg.tfvars
terraform apply -var-file=environments/stg.tfvars

# PRD
terraform init \
  -reconfigure \
  -backend-config=backends/prd.hcl
terraform plan -var-file=environments/prd.tfvars
terraform apply -var-file=environments/prd.tfvars
```

# Tree Architecture
```
aws-infra/
├── child-modules/
│   └── terraform-aws-vpc/
│       ├── versions.tf
│       ├── variables.tf
│       ├── locals.tf
│       ├── vpc.tf
│       ├── subnet.tf
│       ├── nat-gateway.tf
│       ├── route-table.tf
│       └── outputs.tf
│
└── root-modules/
    ├── provider.tf            ← 공통
    ├── variables.tf           ← 공통
    ├── locals.tf              ← 공통
    ├── data.tf                ← 공통
    ├── vpc.tf                 ← 공통
    │
    ├── environments/ 
    │   ├── dev.tfvars         ← 값만 다름
    │   ├── stg.tfvars
    │   └── prd.tfvars
    │
    └── backends/
        ├── dev.hcl            ← State만 다름
        ├── stg.hcl
        └── prd.hcl
```

# 인프라 구성
```
                         Internet
                            │
                         IGW │
                            ▼
                    ┌────────────────┐
                    │    MGMT VPC    │
                    │   10.10.0.0/16 │
                    │                │
                    │ Public Subnet  │
                    │   Bastion EC2  │
                    └───────┬────────┘
                            │
                       VPC Peering
                            │
                            ▼
              ┌─────────────────────────┐
              │      SERVICE VPC        │
              │      10.20.0.0/16       │
              │                         │
              │   Private Subnet A/B    │
              │                         │
              │   ❌ IGW                │
              │   ❌ NAT Gateway        │
              │                         │
              │   ┌─────────────────┐   │
              │   │ VPC Endpoints   │   │
              │   │                 │   │
              │   │ S3              │   │
              │   │ ECR API         │   │
              │   │ ECR DKR         │   │
              │   └─────────────────┘   │
              └────────────┬────────────┘
                           │
                      VPC Peering
                           │
                           ▼
                  ┌────────────────┐
                  │     DB VPC     │
                  │  10.30.0.0/16  │
                  │                │
                  │ Private A/B    │
                  │                │
                  │ ❌ IGW         │
                  │ ❌ NAT         │
                  └────────────────┘
```

## S3 구조
```
root-modules/
├── s3.tf
├── iam.tf
│
├── s3/
│   ├── common/
│   │   ├── eks-loki-admin.yaml
│   │   ├── eks-loki-ruler.yaml
│   │   ├── eks-loki-chunks.yaml
│   │   └── ...
│   │
│   └── environments/
│       ├── dev/
│       ├── stg/
│       └── prd/
│
└── iam/
    ├── common/
    │   ├── loki-role.yaml
    │   └── ...
    │
    └── environments/
        ├── dev/
        ├── stg/
        └── prd/
```