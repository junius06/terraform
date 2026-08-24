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
| [aws_ebs_volume.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.sub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_volume_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ec2_list"></a> [ec2\_list](#input\_ec2\_list) | n/a | <pre>map(object({<br/>    ec2_vpc           = string<br/>    ec2_iam_profile   = string<br/>    ec2_ami           = string<br/>    ec2_instance_type = string<br/>    ec2_keypair       = string<br/>    ec2_root_eni = object({<br/>      ec2_root_eni_subnet            = string<br/>      ec2_root_eni_ip                = string<br/>      ec2_root_eni_sg                = list(string)<br/>      ec2_root_eni_source_dest_check = string<br/>    })<br/>    ec2_sub_eni = list(object({<br/>      ec2_sub_eni_subnet            = string<br/>      ec2_sub_eni_ip                = string<br/>      ec2_sub_eni_sg                = list(string)<br/>      ec2_sub_eni_source_dest_check = string<br/>    }))<br/>    ec2_root_volume = object({<br/>      ec2_root_volume_type       = string<br/>      ec2_root_volume_iops       = string<br/>      ec2_root_volume_throughput = string<br/>      ec2_root_volume_size       = string<br/>      ec2_root_volume_sub_tag    = map(string)<br/>    })<br/>    ec2_sub_volume = list(object({<br/>      ec2_sub_volume_device_name       = string<br/>      ec2_sub_volume_type              = string<br/>      ec2_sub_volume_size              = string<br/>      ec2_sub_volume_iops              = string<br/>      ec2_sub_volume_throughput        = string<br/>      ec2_sub_volume_availability_zone = string<br/>      ec2_sub_volume_sub_tag           = map(string)<br/>    }))<br/>    ec2_encrypt        = string<br/>    ec2_kms_key_arn    = string<br/>    ec2_user_data_file = string<br/>    ec2_tags           = map(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_ec2_root_eni_info"></a> [ec2\_root\_eni\_info](#input\_ec2\_root\_eni\_info) | n/a | <pre>object({<br/>    ec2_name                       = string<br/>    ec2_root_eni_subnet            = string<br/>    ec2_root_eni_ip                = string<br/>    ec2_root_eni_sg                = list(string)<br/>    ec2_root_eni_source_dest_check = string<br/>  })</pre> | n/a | yes |
| <a name="input_ec2_sub_eni_info"></a> [ec2\_sub\_eni\_info](#input\_ec2\_sub\_eni\_info) | n/a | <pre>map(object({<br/>    ec2_name                      = string<br/>    ec2_sub_eni_subnet            = string<br/>    ec2_sub_eni_ip                = string<br/>    ec2_sub_eni_sg                = list(string)<br/>    ec2_sub_eni_source_dest_check = string<br/>  }))</pre> | n/a | yes |
| <a name="input_ec2_user_data"></a> [ec2\_user\_data](#input\_ec2\_user\_data) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2"></a> [ec2](#output\_ec2) | n/a |
<!-- END_TF_DOCS -->