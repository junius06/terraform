######################################
# IAM Role
######################################
resource "aws_iam_role" "this" {
  for_each = var.roles

  name = "${var.context.naming_rule}-${each.key}-role"

  assume_role_policy = (
    data.aws_iam_policy_document.assume_role[
      each.key
    ].json
  )

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = "${var.context.naming_rule}-${each.key}-role"
    }
  )
}


######################################
# Customer Managed Policy
######################################
resource "aws_iam_policy" "this" {
  for_each = local.customer_managed_policies

  name = local.customer_managed_policy_names[each.key]

  description = each.value.description

  policy = data.aws_iam_policy_document.customer_managed[
    each.key
  ].json

  tags = merge(
    var.common_tags,
    {
      Name = local.customer_managed_policy_names[each.key]
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

  name = "${var.context.naming_rule}-${each.key}-profile"

  role = aws_iam_role.this[
    each.key
  ].name

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = "${var.context.naming_rule}-${each.key}-profile"
    }
  )
}