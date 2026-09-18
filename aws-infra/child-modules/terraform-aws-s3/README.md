```
encryption_type = "AES256"
└─ SSE-S3
   └─ bucket_key_enabled → 의미 없음

encryption_type = "aws:kms"
└─ SSE-KMS
   ├─ bucket_key_enabled = false
   │    └─ Object마다 KMS 직접 사용
   │
   └─ bucket_key_enabled = true
        └─ S3 Bucket Key 사용
             → KMS 요청 비용 감소

encryption_type = "aws:kms:dsse"
└─ DSSE-KMS
   └─ S3 Bucket Key 사용 불가
```