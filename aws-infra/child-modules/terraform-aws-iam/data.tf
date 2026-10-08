######################################
# Assume Role Policy (Trust Policy)
######################################
data "aws_iam_policy_document" "assume_role" {
  for_each = var.roles

  statement {
    sid    = "AllowServiceAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = each.value.services
    }
  }
}


######################################
# Customer Managed Policy Document
######################################
data "aws_iam_policy_document" "customer_managed" {
  for_each = local.customer_managed_policies

  dynamic "statement" {
    for_each = each.value.statement

    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}