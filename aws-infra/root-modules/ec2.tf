module "ec2" {
  source = "../child-modules/terraform-aws-ec2"
  
  instances = {
    for instance_name, instance in local.ec2_instances :

    instance_name => {
      #### Instance
      ami_id = data.aws_ssm_parameter.al2023_arm64.value
      instance_type = instance.instance_type

      key_name = instance.key_name

      iam_instance_profile = (
        instance.iam_instance_profile
      )

      monitoring = instance.monitoring

      #### Network
      subnet_id = (
        instance.network.subnet_type == "public"
        ? module.vpc[
          instance.network.vpc_name
        ].public_subnet_id[
          "${instance.network.subnet_group}-${instance.zone}"
        ].id
        : module.vpc[
          instance.network.vpc_name
        ].private_subnet_id[
          "${instance.network.subnet_group}-${instance.zone}"
        ].id
      )

      security_group_ids = [
        for sg_name in instance.security_groups :
        module.sg.security_group_ids[
          "${instance.network.vpc_name}/${sg_name}"
        ]
      ]

      associate_public_ip_address = (
        instance.associate_public_ip_address
      )

      #### Elastic IP
      eip = instance.eip

      #### User Data
      user_data =(
        instance.user_data_file != null
        ? file(
          "${path.module}/ec2/user-data/${instance.user_data_file}"
        )
        : null
      )

      #### Root & Additional EBS Volume
      root_volume = instance.root_volume
      ebs_volumes = instance.ebs_volumes

      #### Tags
      tags = instance.tags
    }
  }

  ipa_user = local.ipa_user
  common_tags = local.common_tags
}