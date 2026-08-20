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
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_private_subnet"></a> [private\_subnet](#input\_private\_subnet) | Map of private subnets | <pre>list(object({<br/>    subnet_cidr = string<br/>    tags        = map(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_public_nat_gateway_subnets"></a> [public\_nat\_gateway\_subnets](#input\_public\_nat\_gateway\_subnets) | Subnets for NAT placement | `list(string)` | n/a | yes |
| <a name="input_public_subnet"></a> [public\_subnet](#input\_public\_subnet) | Map of public subnets | <pre>list(object({<br/>    subnet_cidr = string<br/>    tags        = map(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR Block for the VPC | `string` | n/a | yes |
| <a name="input_vpc_flow_log_s3_name"></a> [vpc\_flow\_log\_s3\_name](#input\_vpc\_flow\_log\_s3\_name) | VPC Flow Log S3 Bucket Name | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pri_rtb"></a> [pri\_rtb](#output\_pri\_rtb) | route 모듈의 pri\_route\_table\_info 변수에 활용 |
| <a name="output_pri_sbn"></a> [pri\_sbn](#output\_pri\_sbn) | n/a |
| <a name="output_pub_sbn"></a> [pub\_sbn](#output\_pub\_sbn) | n/a |
| <a name="output_target_nat_exist"></a> [target\_nat\_exist](#output\_target\_nat\_exist) | route.tf 변수에 NAT 정보 저장 용도 |
| <a name="output_target_nat_info"></a> [target\_nat\_info](#output\_target\_nat\_info) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | sg.tf 모듈에 depend\_on 용도 |
<!-- END_TF_DOCS -->