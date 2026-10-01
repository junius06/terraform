1. Child-Modules (EC2 + Root EBS + Additional EBS + EIP 생성)
  1. variables.tf
  2. locals.tf
  3. main.tf
  4. outputs.tf
2. Root-Modules 
  1. eks-mgmt.yaml 파일 작성 완료
  2. userdata eks-mgmt.sh 작성 완료
  3.


######################################
# EC2
######################################

module "ec2" {
  source = "../child-modules/terraform-aws-ec2"

  instances = {
    for instance_name, instance in local.ec2_instances :

    instance_name => {

      ################################
      # Instance
      ################################

      ami_id = data.aws_ssm_parameter.al2023_arm64.value

      instance_type = instance.instance_type

      key_name = instance.key_name

      iam_instance_profile = (
        instance.iam_instance_profile
      )

      monitoring = instance.monitoring


      ################################
      # Network
      ################################

      subnet_id = (
        instance.network.subnet_type == "public"
        ? module.vpc[
            instance.network.vpc_name
          ].public_subnet_id[
            "${instance.network.subnet_group}-${instance.zone}"
          ]
        : module.vpc[
            instance.network.vpc_name
          ].private_subnet_id[
            "${instance.network.subnet_group}-${instance.zone}"
          ]
      )

      # Security Group module will be connected later.
      security_group_ids = []

      associate_public_ip_address = (
        instance.associate_public_ip_address
      )


      ################################
      # Elastic IP
      ################################

      eip = instance.eip


      ################################
      # User Data
      ################################

      user_data = (
        instance.user_data_file != null
        ? file(
            "${path.module}/ec2/user-data/${instance.user_data_file}"
          )
        : null
      )


      ################################
      # Root Volume
      ################################

      root_volume = instance.root_volume


      ################################
      # Additional EBS Volumes
      ################################

      ebs_volumes = instance.ebs_volumes


      ################################
      # Tags
      ################################

      tags = instance.tags
    }
  }

  common_tags = local.common_tags
}