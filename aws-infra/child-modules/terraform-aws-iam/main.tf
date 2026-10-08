######################################
# IAM Role
######################################
resource "aws_iam_role" "this" {
  for_each = var.roles

  name = "${var.context.naming_rule}-role-${each.key}"

  assume_role_policy = (
    data.aws_iam_policy_document.assume_role[
      each.key
    ].json
  )

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = "${var.context.naming_rule}-role-${each.key}"
    }
  )
}


######################################
# Customer Managed Policy
######################################
resource "aws_iam_policy" "this" {
  for_each = local.customer_managed_policies

  name = ("${var.context.naming_rule}-policy-${each.value.role_key}-${each.value.policy_name}")

  description = each.value.description

  policy = data.aws_iam_policy_document.customer_managed[
    each.key
  ].json

  tags = merge(
    var.common_tags,
    {
      Name = "${var.context.naming_rule}-policy-${each.value.role_key}-${each.value.policy_name}"
    }
  )
}


######################################
# AWS Managed Policy Attachment
######################################
resource "aws_iam_role_policy_attachment" "aws_managed" {
  for_each = local.aws_managed_policy_attachments

  role = aws_iam_role.this[
    each.value.role_key
  ].name

  policy_arn = each.value.policy_arn
}


######################################
# Customer Managed Policy Attachment
######################################
resource "aws_iam_role_policy_attachment" "customer_managed" {
  for_each = local.customer_managed_policies

  role = aws_iam_role.this[
    each.value.role_key
  ].name

  policy_arn = aws_iam_policy.this[
    each.key
  ].arn
}


######################################
# IAM Instance Profile
######################################
resource "aws_iam_instance_profile" "this" {
  for_each = local.instance_profiles

  name = "${var.context.naming_rule}-profile-${each.key}"

  role = aws_iam_role.this[
    each.key
  ].name

  tags = merge(
    var.common_tags,
    each.value.tags
    {
      Name = "${var.context.naming_rule}-profile-${each.key}"
    }
  )
}