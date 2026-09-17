| VPC Module Output | RT Module에서 필요한 이유                                 |
| ----------------- | ------------------------------------------------------ |
| `vpc_id`          | Route Table을 어느 VPC에 생성할지                         |
| `public_subnets`  | Public RT 생성 및 Subnet Association                     |
| `private_subnets` | Private RT 생성 및 Subnet Association                    |
| `igw_id`          | Public RT의 `0.0.0.0/0 → IGW`                           |
| `nat_gateways`    | `enable_nat=true` Private RT의 `0.0.0.0/0 → 동일 AZ NAT` |
