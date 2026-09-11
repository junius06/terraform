# buckets.csv 파일 작성법  

| name            | purpose      | versioning | public_access_block | encryption | policy_file             |
|-----------------|--------------|------------|---------------------|------------|-===========-------------|
|svc-vpc-flow-log | vpc-flow-log | false      | true                | AES256     | vpc-flow-log.json.tftpl |

name : 논리적인 이름만 넣는다.  
실제 생성 이름은 root에서 `${project}-${environment}-${region_name}-${name}`으로 생성된다.
예) `prj-dev-oregon-svc-vpc-flow-log`