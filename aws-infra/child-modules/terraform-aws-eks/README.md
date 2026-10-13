```
aws-infra/
├── child-modules/
│   └── terraform-aws-eks/
│       ├── variables.tf
│       ├── locals.tf
│       ├── main.tf
│       └── outputs.tf
│
└── root-modules/
    ├── eks.tf
    ├── locals.tf
    ├── ...
    └── eks/
        ├── cluster/
        │   ├── example.yaml
        │   ├── workload.yaml
        │   └── monitoring.yaml
        │
        └── node-groups/
            ├── example.yaml
            ├── svc.yaml
            ├── obs.yaml
            └── mgt.yaml
```

| 구분                   | 역할                                    |
|------------------------|-----------------------------------------|
| eks/cluster/*.yaml	 | 생성할 Cluster 및 사용할 Node Group 지정 |
| eks/node-groups/*.yaml | Node Group별 설정 정의 |
| Root locals.tf	     | YAML 로드, 참조 검증, Cluster별 Node Group 결합 |
| Root eks.tf	         | VPC, IAM, SG 참조 해결 및 Child 호출 |
| Child Module	         | EKS Cluster와 Managed Node Group 생성 |