#!/bin/bash

#####################################
# 환경 설정
#####################################
# IMDSv2 사용을 위한 TOKEN 발급
TOKEN=$(curl -s -X PUT \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
    http://169.254.169.254/latest/api/token)

# 현재 EC2의 Region 조회
REGION=$(curl -sS \
    -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/placement/region)

# 조회된 Region에 따라 eu, us, cn 설정
if [ $REGION = "eu-west-1" ]; then
    REGION_CODE="eu"
elif [ $REGION = "us-west-2" ]; then
    REGION_CODE="us"
elif [ $REGION = "ap-southeast-1" ]; then
    REGION_CODE="cn"
else
    echo "ERROR: Unknown REGION. The current region is $REGION." >&2
    exit 1
fi

# 환경 선택 (Input)
read -p "Set Environment (dev/stg/prd): " ENV

case "$ENV" in
    dev|stg|prd)
        echo "The current environment is $ENV."
        ;;
    *)
        echo "ERROR: Invalid environment: $ENV" >&2
        echo "Allowed values: dev, stg, prd" >&2
        exit 1
        ;;
esac

echo "Region: $REGION"
echo "Env: $ENV"

#####################################
# DOWNLOAD TERRAFORM CODE FROM GITHUB
#####################################
echo "Downloading Terraform code..."

# Root Modules Repository URL
git clone terraform-aws-root-modules BRANCH
# Child Modules Repository URL
git clone terraform-aws-vpc

#####################################
# TERRAFORM
#####################################
# terraform root-module 경로
cd terraform-aws-root-modules

# 초기화
ENV_FILE="${EMV}-${REGION}"
terraform init -backend-config="./backends/${ENV_FILE}.hcl"
terraform plan -lock=false -var-file="./tfvars-env/${ENV_FILE}.tfvars"
terraform apply -var-file="./tfvars-env/${ENV_FILE}.tfvars" -auto-approve

terraform init -backend-config="./backends/dev-eu.hcl"
terraform plan -lock=false -var-file="./tfvars-env/dev-eu.tfvars"
terraform apply -var-file="./tfvars-env/dev-eu.tfvars" -auto-approve
terraform destroy -var-file="./tfvars-env/dev-eu.tfvars" -auto-approve