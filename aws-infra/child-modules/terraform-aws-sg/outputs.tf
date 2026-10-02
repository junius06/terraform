output "security_group_ids" {
  description = "Security Group IDs"

  value = {
    for key, sg in aws_security_group.this :
    key => sg.id
  }
}