# 차후 정리해야 할 내용
1. ROOT, CHILD 각각 생성되는 TAG 종류


# 각 모듈의 컨셉
## 1. VPC

## 2. VPC-PEER

## 3. ROUTE

## 4. S3

## 5. EC2
### Root/Child Module Concept
- Root  = YAML/UserData 파일 탐색·해석 + AWS 리소스 간 연결
- Child = 전달받은 최종 설정으로 EC2/EIP/EBS 생성

### Flow
```
terraform apply
      │
      ▼
root-modules/ec2.tf
      │
      ├─ root-modules/ec2/*.yaml 탐색
      │
      ├─ YAML 파일명 → EC2 종류 이름
      │
      ├─ ec2_count만큼 인스턴스 설정 확장
      │
      ├─ UserData.sh 읽기
      │
      └─ VPC/Subnet 등의 실제 ID 해석
      │
      ▼
child-modules/terraform-aws-ec2
      │
      ├─ aws_instance
      ├─ aws_eip
      ├─ aws_ebs_volume
      └─ aws_volume_attachment
```

### 설명
- terraform 실행 시, root-modules/ec2.tf 파일에 선언된 ec2를 생성하도록 실행됨
- ec2.tf 파일이 실행되면서 root-modules/ec2/<ec2-name>.yaml 파일에 정의된 인스턴스들을 생성. (단, yaml파일에 ec2_count 변수를 둠.
- UserData는 root-modules/ec2/uesr-data/<userdata-name>.sh로 정의하여, yaml 파일에서 필요한 userdata 값을 불러옴.
- root-modules/ec2/ 하위에 어떤 yaml파일도 존재하지 않을 경우 EC2 생성하지 않고 지나감. (경고 메세지도 없고, 메세지 한 줄만 출력. ㅡ "EC2가 정의되지 않아 생성하지 않습니다.")
- root-modules/ec2.tf 에서 생성하고자 하는 yaml 파일을 읽으면, child-modules이 내용을 전달받아 정의된 yaml파일을 읽어서 필요한 ec2를 생성함.
- EC2 Tag Name : ${local.naming_rule}-<ec2-name>-<count index><zone>
- YAML 파일의 Count가 1일 경우 한 대만 생성되며, Count 갯수만큼 순서대로 <count index>가 부여되고 홀수 index zone=a, 짝수 index zone=b 설정됨.
| index | instance_number | `index % 2` | zone | Name suffix |
|------:|----------------:|------------:|------|-------------|
| 0     | 1               | 0           | a    | `1a`        |
| 1     | 2               | 1           | b    | `2b`        |
| 2     | 3               | 0           | a    | `3a`        |
| 3     | 4               | 1           | b    | `4b`        |
| 4     | 5               | 0           | a    | `5a`        |
| 5     | 6               | 1           | b    | `6b`        |



## 6. SG

## 7. IAM
Role Naming Rule = {project}-{environment}-{region_name}-role-{yaml_file_name}
Customer Managed Policy Naming Rule = {project}-{environment}-{region_name}-policy-{yaml_file_name}-{policy_name}

IAM YAML
 ├─ Trust 대상 Service
 ├─ Instance Profile 생성 여부
 ├─ AWS Managed Policy
 ├─ Customer Managed Policy
 └─ Tags

        ↓ Root

YAML 검색 / Parsing / 정규화

        ↓ Child

IAM Role
IAM Customer Managed Policy
Policy Attachment
Instance Profile

        ↓ Output

EC2에서 Instance Profile 참조