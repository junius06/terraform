Root  = YAML/UserData 파일 탐색·해석 + AWS 리소스 간 연결
Child = 전달받은 최종 설정으로 EC2/EIP/EBS 생성


terraform 실행 시, root-modules/ec2.tf 파일에 선언된 ec2를 생성하도록 실행됨

ec2.tf 파일이 실행되면서 root-modules/ec2/<ec2-name>.yaml 파일에 정의된 인스턴스들을 생성. (단, yaml파일에 ec2_count 변수를 둠. count가 1일 경우 한 대만 생성되며 ec2 Tag Name은 ${local.naming_rule}-<ec2-name>-<count number><zone> 로 자동 설정됨.

UserData는 root-modules/ec2/uesr-data/<userdata-name>.sh로 정의하여, yaml 파일에서 필요한 userdata 값을 불러옴.

root-modules/ec2/ 하위에 어떤 yaml파일도 존재하지 않을 경우 EC2 생성하지 않고 지나감. (경고 메세지도 없고, 메세지 한 줄만 출력. ㅡ "EC2가 정의되지 않아 생성하지 않습니다.")

root-modules/ec2.tf 에서 생성하고자 하는 yaml 파일을 읽으면, child-modules이 내용을 전달받아 정의된 yaml파일을 읽어서 필요한 ec2를 생성함.



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
      ├─ UserData .sh 읽기
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