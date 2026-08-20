<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.eu-accepter"></a> [aws.eu-accepter](#provider\_aws.eu-accepter) | n/a |
| <a name="provider_aws.us-accepter"></a> [aws.us-accepter](#provider\_aws.us-accepter) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_vpc_peering_connection.eu_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection.us_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.eu_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_accepter.us_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_options.eu_region_accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_vpc_peering_connection_options.eu_region_requester](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_vpc_peering_connection_options.us_region_accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_vpc_peering_connection_options.us_region_requester](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_peer_info"></a> [vpc\_peer\_info](#input\_vpc\_peer\_info) | n/a | <pre>map(object({<br/>    vpc_peer_name = string<br/>    vpc_peer_requester_config = object({<br/>      requester_vpc     = string<br/>      requester_account = string<br/>      requester_region  = string<br/>    })<br/>    vpc_peer_accepter_config = object({<br/>      accepter_vpc     = string<br/>      accepter_account = string<br/>      accepter_region  = string<br/>    })<br/>    vpc_peer_sub_tags = map(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_target_vpc_peer_exist_eu"></a> [target\_vpc\_peer\_exist\_eu](#output\_target\_vpc\_peer\_exist\_eu) | EU - requester 기준 |
| <a name="output_target_vpc_peer_exist_us"></a> [target\_vpc\_peer\_exist\_us](#output\_target\_vpc\_peer\_exist\_us) | route.tf 변수에 Peering 정보 저장 용도 US - requester 기준 |
| <a name="output_target_vpc_peer_info_eu"></a> [target\_vpc\_peer\_info\_eu](#output\_target\_vpc\_peer\_info\_eu) | n/a |
| <a name="output_target_vpc_peer_info_us"></a> [target\_vpc\_peer\_info\_us](#output\_target\_vpc\_peer\_info\_us) | n/a |
<!-- END_TF_DOCS -->