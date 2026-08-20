<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_object_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_s3_info"></a> [s3\_info](#input\_s3\_info) | n/a | <pre>map(object({<br/>    s3_kms_arn     = string<br/>    s3_versioning  = string<br/>    s3_tags        = map(string)<br/>    s3_object_lock = string<br/>    s3_logging = object({<br/>      s3_logging_target                   = string<br/>      s3_logging_target_prefix            = string<br/>      s3_logging_target_object_key_format = string<br/>      s3_logging_partitioned_prefix_type  = string<br/>    })<br/>    s3_lifecycle = list(object({<br/>      s3_lifecycle_rule_name   = string<br/>      s3_lifecycle_rule_status = string<br/>      s3_lifecycle_rule_filter = list(object({<br/>        object_size_greater_than = string<br/>        object_size_less_than    = string<br/>        prefix                   = string<br/>        tags                     = map(string)<br/>      }))<br/>      s3_lifecycle_rule_transition = list(object({<br/>        days          = string<br/>        storage_class = string<br/>      }))<br/>      s3_lifecycle_rule_expiration = object({<br/>        days = string<br/>      })<br/>    }))<br/>    s3_policy = any<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->