#!/bin/bash

# 1. IPA 설치
systemctl restart sshd

## 2. OpenTelemetry Agent 설치

## 3. 스크립트 다운로드를 위한 경로 생성 + 패키지 다운로드를 위한 스크립트 다운로드
# mkdir -p /shared-data
# aws s3 cp s3://경로/스크립트 /shared-data/스크립트
# chmod 777 /shared-data
# chmod 777 /shared-data/스크립트

# 필수 패키지 설치
# 1. kubectl
# 2. helm
# 3. k9s
# 4. kubectx, kubens
# 5. nodeviewer