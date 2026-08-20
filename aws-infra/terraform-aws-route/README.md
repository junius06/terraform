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
| [aws_route.gwlb_route_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_route_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.tgw_route_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.vpc_peer_rules_eu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.vpc_peer_rules_us](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pri_route_table_info"></a> [pri\_route\_table\_info](#input\_pri\_route\_table\_info) | ### Pri RTB | `any` | `null` | no |
| <a name="input_route_rules"></a> [route\_rules](#input\_route\_rules) | n/a | <pre>list(object({<br/>    dst_cidr_block = string<br/>    id             = string<br/>    route_table    = string<br/>    target         = string<br/>    target_type    = string<br/>  }))</pre> | n/a | yes |
| <a name="input_target_gwlb_ep_exist"></a> [target\_gwlb\_ep\_exist](#input\_target\_gwlb\_ep\_exist) | ### GWLB | `list(string)` | `null` | no |
| <a name="input_target_gwlb_ep_info"></a> [target\_gwlb\_ep\_info](#input\_target\_gwlb\_ep\_info) | n/a | `any` | `null` | no |
| <a name="input_target_nat_exist"></a> [target\_nat\_exist](#input\_target\_nat\_exist) | ### NAT | `list(string)` | `null` | no |
| <a name="input_target_nat_info"></a> [target\_nat\_info](#input\_target\_nat\_info) | n/a | `any` | `null` | no |
| <a name="input_target_tgwa_exist"></a> [target\_tgwa\_exist](#input\_target\_tgwa\_exist) | ### TGWA | `list(string)` | `null` | no |
| <a name="input_target_tgwa_info"></a> [target\_tgwa\_info](#input\_target\_tgwa\_info) | n/a | `any` | `null` | no |
| <a name="input_target_vpc_peer_exist_eu"></a> [target\_vpc\_peer\_exist\_eu](#input\_target\_vpc\_peer\_exist\_eu) | ### VPC Peer EU | `any` | `[]` | no |
| <a name="input_target_vpc_peer_exist_us"></a> [target\_vpc\_peer\_exist\_us](#input\_target\_vpc\_peer\_exist\_us) | ### VPC Peer US | `any` | `[]` | no |
| <a name="input_target_vpc_peer_info_eu"></a> [target\_vpc\_peer\_info\_eu](#input\_target\_vpc\_peer\_info\_eu) | n/a | `any` | `null` | no |
| <a name="input_target_vpc_peer_info_us"></a> [target\_vpc\_peer\_info\_us](#input\_target\_vpc\_peer\_info\_us) | n/a | `any` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->