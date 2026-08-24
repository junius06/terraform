<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_access_entry.reserved_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_entry.service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_entry.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.reserved_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_access_policy_association.service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_access_policy_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_pod_identity_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_info"></a> [eks\_cluster\_info](#input\_eks\_cluster\_info) | n/a | <pre>map(object({<br/>    eks_cluster_name                    = string<br/>    eks_cluster_version                 = string<br/>    eks_cluster_role_arn                = string<br/>    eks_cluster_auth_mode               = string<br/>    eks_cluster_allow_admin_access      = string<br/>    eks_cluster_secret_enc_kms_key_arn  = string<br/>    eks_cluster_tags                    = map(string)<br/>    eks_cluster_vpc                     = string<br/>    eks_cluster_subnets                 = list(string)<br/>    eks_cluster_security_group          = list(string)<br/>    eks_cluster_public_endpoint_access  = string<br/>    eks_cluster_private_endpoint_access = string<br/>    eks_cluster_service_ipv4_cidr       = string<br/>    eks_cluster_enabled_log_types       = list(string)<br/>    eks_cluster_addon = list(object({<br/>      name     = string<br/>      version  = string<br/>      role_arn = string<br/>    }))<br/>    eks_node_group = list(object({<br/>      eks_node_group_name     = string<br/>      eks_node_group_role_arn = string<br/>      eks_node_group_subnets  = list(string)<br/>      eks_node_group_scaling = object({<br/>        min_size     = string<br/>        max_size     = string<br/>        desired_size = string<br/>      })<br/>      eks_node_group_update_config = object({<br/>        max_unavailable_type  = string<br/>        max_unavailable_value = string<br/>      })<br/>      eks_node_group_tags = map(string)<br/>    }))<br/>    eks_launch_template = list(object({<br/>      eks_launch_template_name           = string<br/>      eks_launch_template_ami            = string<br/>      eks_launch_template_instance_type  = string<br/>      eks_launch_template_security_group = list(string)<br/>      eks_launch_template_root_volume = object({<br/>        volume_device_name = string<br/>        volume_size        = string<br/>        volume_type        = string<br/>        volume_iops        = string<br/>        volume_kms_key_id  = string<br/>      })<br/>      eks_launch_template_sub_volume = list(object({<br/>        volume_device_name = string<br/>        volume_size        = string<br/>        volume_type        = string<br/>        volume_iops        = string<br/>        volume_kms_key_id  = string<br/>      }))<br/>      eks_launch_template_resource_tags = list(object({<br/>        resource_type = string<br/>        resource_tag  = map(string)<br/>      }))<br/>      eks_launch_template_tags = map(string)<br/>    }))<br/>    eks_cluster_iam_access = list(object({<br/>      iam_arn    = string<br/>      policy_arn = string<br/>    }))<br/>    eks_cluster_pod_identity = list(object({<br/>      iam_arn         = string<br/>      namespace       = string<br/>      service_account = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_eks_cluster_sg_id"></a> [eks\_cluster\_sg\_id](#input\_eks\_cluster\_sg\_id) | n/a | `list(string)` | n/a | yes |
| <a name="input_eks_cluster_subnet_id"></a> [eks\_cluster\_subnet\_id](#input\_eks\_cluster\_subnet\_id) | n/a | `list(string)` | n/a | yes |
| <a name="input_eks_launch_template_sg_id"></a> [eks\_launch\_template\_sg\_id](#input\_eks\_launch\_template\_sg\_id) | n/a | `any` | n/a | yes |
| <a name="input_eks_node_group_subnet_id"></a> [eks\_node\_group\_subnet\_id](#input\_eks\_node\_group\_subnet\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster"></a> [eks\_cluster](#output\_eks\_cluster) | n/a |
<!-- END_TF_DOCS -->