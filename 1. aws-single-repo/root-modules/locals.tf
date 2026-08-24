locals {
  region_map = {
    "eu-west-1" = {
      name = "ireland"
      code = "ew1"
    }

    "us-west-2" = {
      name = "oregon"
      code = "uw2"
    }

    "ap-northeast-2" = {
      name = "seoul"
      code = "an2"
    }
  }

  region_name = local.region_map[var.aws_region].name
  region_code = local.region_map[var.aws_region].code

  # ECR
  ecr_repository_arns = [
    for repository_name in var.ecr_repositories :
    "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${repository_name}"
  ]

  # S3
  s3_bucket_arns = flatten([
    for bucket_name in var.s3_buckets : [
      "arn:aws:s3:::${bucket_name}",
      "arn:aws:s3:::${bucket_name}/*"
    ]
  ])

  # TAGS
  common_tags = {
    project = var.project
  }
}