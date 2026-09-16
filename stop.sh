#!/bin/bash

#####################################
# IMDSv2 Token 발급
#####################################
TOKEN=$(curl -s -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

#####################################
# Role에서 Admin권한 제거
#####################################
# 현재 EC2에 연결된 IAM Role 이름 확인
ROLE_NAME=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/)

ROLE_POLICY=$(aws iam list-attached-role-policies --role-name "$ROLE_NAME")

echo "Before Detach Admin-Policy List: $ROLE_POLICY"

# 현재 Role에 연결된 Admin Policy 제거
aws iam detach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess


#####################################
# SG Outbound 0.0.0.0/0 443 제거
#####################################
# 현재 EC2의 Security Group ID 조회
SG_IDS=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/network/interfaces/macs/$(curl -s \
    -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/mac)/security-group-ids)

echo "Attached Security Groups List: $SG_IDS"
echo

# 각 SG에서 Outbound TCP 443 → 0.0.0.0/0 제거
echo "연결된 Security Groups Outbound Port 443 0.0.0.0/0 제거합니다."
for SG_ID in $SG_IDS; do
  echo "Processing: $SG_ID"

  aws ec2 revoke-security-group-egress \
    --group-id "$SG_ID" \
    --ip-permissions \
      'IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=0.0.0.0/0}]'
done


#####################################
# 점검
#####################################
CHECK_FAILED=0

## 1. AdministratorAccess 제거 확인
echo "Checking AdministratorAccess policy..."

ADMIN_POLICY=$(aws iam list-attached-role-policies \
  --role-name "$ROLE_NAME" \
  --query "AttachedPolicies[?PolicyArn=='arn:aws:iam::aws:policy/AdministratorAccess'].PolicyArn" \
  --output text 2>/dev/null)

if [ -z "$ADMIN_POLICY" ]; then
  echo "[PASS] AdministratorAccess has been detached."
else
  echo "[FAIL] AdministratorAccess is still attached." >&2
  CHECK_FAILED=1
fi

## 2. Security Group Egress 제거 확인
echo "Checking Security Group outbound rules..."

for SG_ID in $SG_IDS; do

  EGRESS_RULE=$(aws ec2 describe-security-groups \
    --group-ids "$SG_ID" \
    --query "SecurityGroups[0].IpPermissionsEgress[?IpProtocol=='tcp' && FromPort==\`443\` && ToPort==\`443\`].IpRanges[?CidrIp=='0.0.0.0/0'].CidrIp" \
    --output text 2>/dev/null)

  if [ -z "$EGRESS_RULE" ]; then
    echo "[PASS] $SG_ID: TCP 443 -> 0.0.0.0/0 has been removed."
  else
    echo "[FAIL] $SG_ID: TCP 443 -> 0.0.0.0/0 still exists." >&2
    CHECK_FAILED=1
  fi

done

## 최종 결과
if [ "$CHECK_FAILED" -eq 0 ]; then
  echo "Cleanup verification completed successfully."
else
  echo "ERROR: Cleanup verification failed." >&2
  exit 1
fi