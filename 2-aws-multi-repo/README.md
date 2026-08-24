# 사용법
## 1. Bastion Instance 접속
Bastion Instance는 AWS Console 에서 수동 생성 및 관리  
- IAM Role : TerraformRole  
- terraform 실행 권한이 있어야 한다.  
Instance Profile / IAM Role -> AWS 임시 Credential -> Terraform AWS Provider -> aws_caller_identity -> Account = 111111111111

## AWS Account
** Bastion Instance
```
# bastion 접속해서 아래 명령어 확인
aws sts get-caller-identity
```

## 테라폼 초기화 & tfstat 파일 불러오기
```
# Account ID
export TF_VAR_aws_account_id=$(aws sts get-caller-identity \
  --query Account \
  --output text)

terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## 환경에 따라 파일의 내용이 다른 것
- backend.hcl (제일 중요)
- terraform.tfvars


# ROOT MODULE
terraform-root

# CHILD MODULES
terraform-aws-<module-name>

# TREE 
```
aws-infra/
├── child-modules/
│   └── terraform-aws-vpc/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
│
└── root-modules/
    ├── dev/
    │   ├── provider.tf
    │   ├── backend.hcl
    │   ├── data.tf
    │   ├── variables.tf
    │   ├── terraform.tfvars
    │   ├── locals.tf
    │   ├── vpc.tf
    │   └── outputs.tf
    │
    ├── stg/
    │   └── ...
    │
    └── prd/
        └── ...
```

# ACCOUNT 인증방식 / Multi-Account
`root-modules/data.tf` 에서 `aws_caller_identity`로 현재 Account_ID를 가져오는 방식.  
어떤 AWS Account를 사용하는지 AWS Provider의 Credential이 결정한다.  
AWS Credential -> provider "aws" -> AWS Account 접속 -> aws_caller_identity -> Account ID 확인  