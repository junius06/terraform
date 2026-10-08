output "role_names" {
  description = "IAM Role Names"

  value = {
    for key, role in aws_iam_role.this :
    key => role.name
  }
}

output "role_arns" {
  description = "IAM Role ARNs"

  value = {
    for key, role in aws_iam_role.this :
    key => role.arn
  }
}