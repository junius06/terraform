module "ec2" {
  source = "../child-modules/terraform-aws-ec2"
  
  instances = {
    for instance_name, instance in local.ec2_instances :

    instance_name => {
      # Instance
      ami_id = instance.ami_id
      instance_type = instance.instance_type

      key_name = try(
        instance.key_name, null
      )

      iam_instance_profile = try(
        instance.iam_instance_profile, null
      )

      monitoring = try(
        instance.monitoring, false
      )

      # Network
    }
  }
  ipa_user = local.ipa_user

  user_data = (
    try(instance.user_data.file, null) != null
    ? file("${path.module}/ec2/user-data/${instance.user_data.file}")
    : null
  )
}