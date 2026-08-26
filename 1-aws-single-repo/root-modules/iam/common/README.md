aws-infra/
├── child-modules/
│   ├── terraform-aws-vpc/
│   │
│   └── terraform-aws-iam-role/       ← 범용 IAM Role 생성 모듈
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── root-modules/
    ├── iam.tf                         ← IAM Roles 모듈 호출
    │
    ├── iam/
    │   └── roles/                     ← 하나의 Child Module
    │       ├── variables.tf
    │       ├── outputs.tf
    │       ├── bastion.tf
    │       ├── eks-cluster.tf
    │       ├── eks-node.tf
    │       └── rds-monitoring.tf
    │
    ├── ec2.tf
    ├── eks.tf
    ├── rds.tf
    └── ...



root-modules
      │
      │ iam.tf
      ▼
iam/roles
      │
      ├── bastion.tf
      ├── eks-cluster.tf
      ├── eks-node.tf
      └── rds-monitoring.tf
              │
              ▼
child-modules/terraform-aws-iam-role


                 iam/roles/
                     │
        ┌────────────┼─────────────┐
        │            │             │
        ▼            ▼             ▼
    bastion      eks-cluster    eks-node
        │            │             │
        ▼            ▼             ▼
Instance Profile   Role ARN       Role ARN
        │            │             │
        ▼            ▼             ▼
     EC2         EKS Cluster    Node Group