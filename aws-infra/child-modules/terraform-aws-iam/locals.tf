######################################
# AWS Managed Policy Attachments
######################################
locals {
  aws_managed_policy_attachments = merge(
    {},
    [
      for role_key, role in var.roles : {
        for index, policy_arn in role.aws_managed_policies :

        "${role_key}-aws-${index + 1}" => {
          role_key   = role_key
          policy_arn = policy_arn
        }
      }
    ]...
  )
}


######################################
# Customer Managed Policies
######################################
locals {
  customer_managed_policies = merge(
    {},
    [
      for role_key, role in var.roles : {
        for policy_name, policy in role.policies :

        "${role_key}/${policy_name}" => {
          role_key    = role_key
          policy_name = policy_name

          description = policy.description
          statements  = policy.statements
        }
      }
    ]...
  )
}


######################################
# Instance Profiles
######################################
locals {
  instance_profiles = {
    for role_key, role in var.roles :

    role_key => role
    if role.instance_profile_enabled
  }
}