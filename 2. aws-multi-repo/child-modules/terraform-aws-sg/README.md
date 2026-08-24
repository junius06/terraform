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
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.cidr_block_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.prefix_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.src_sg_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sg_rules"></a> [sg\_rules](#input\_sg\_rules) | n/a | <pre>list(object({<br/>    id               = string<br/>    sg_name          = string<br/>    rule_description = string<br/>    from_port        = string<br/>    to_port          = string<br/>    protocol_type    = string<br/>    cidr_block       = string<br/>    prefix_id        = string<br/>    src_sg           = string<br/>    type             = string<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sg"></a> [sg](#output\_sg) | Security Group을 사용하는 모든 리소스가 참조(Depends\_on) ex)ec2, vpce, rds 등등 |
<!-- END_TF_DOCS -->