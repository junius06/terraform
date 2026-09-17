1. 디렉터리 구조
```
terraform-aws-route/
├── variables.tf
├── locals.tf
├── route-table.tf
├── route.tf
├── association.tf
└── outputs.tf
```

2. route_table.csv enable을 위한 순서
```
현재 VPC가 enable_additional_routes=true?
            │
       ┌────┴────┐
      NO         YES
      │           │
     [ ]      CSV 데이터 확인
                  │
                  ▼
            현재 VPC만 선택
         route.vpc == each.key
                  │
                  ▼
              Child 전달
```

3. NAT Gateway 배치
```
enable_nat = true
             ↓
enable된 Private Subnet의 AZ(a/b) 확인
             ↓
NAT-Subnet과 동일한 AZ에 존재하는 NAT 검색
             ↓
 ┌───────────┼───────────┐
 0개        1개        2개 이상
 ↓           ↓           ↓
ERROR   해당 NAT 사용   ERROR (향후 필요시 해당 설정 필요)
```

4. 최종적 Child Module ㅡ Route 동작
```
terraform-aws-vpc
       │
       ├── vpc_id
       ├── public_subnets
       ├── private_subnets
       ├── igw_id
       └── nat_gateways
              │
              ▼
     terraform-aws-route
              │
      ┌───────┴────────┐
      │                │
    Public           Private
      │                │
 Group별 RT        Subnet/AZ별 RT
      │                │
 0/0 → IGW       enable_nat?
      │                │
 Association      ┌─────┴─────┐
                  NO          YES
                  │            │
             Association   동일 AZ NAT 검색
                               │
                       ┌───────┼────────┐
                       0       1       2+
                       │       │        │
                      FAIL    NAT      FAIL
                               │
                         Association
```
- tfvars 파일에서 public_subnets에 속한 subnet group은 route table에 자동으로 igw가 연결된다.