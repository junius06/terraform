######################################
# EC2
######################################
output "instance_ids" {
  description = "EC2 instance IDs"

  value = {
    for name, instance in aws_instance.this :
    name => instance.id
  }
}


output "instance_names" {
  description = "EC2 instance names"

  value = {
    for name, instance in aws_instance.this :
    name => instance.tags["Name"]
  }
}

output "private_ips" {
  description = "EC2 private IP addresses"

  value = {
    for name, instance in aws_instance.this :
    name => instance.private_ip
  }
}


######################################
# EIP
######################################
output "eip_addresses" {
  description = "Elastic IP addresses"

  value = {
    for name, eip in aws_eip.this :
    name => eip.public_ip
  }
}


######################################
# Additional EBS
######################################
output "ebs_volume_ids" {
  description = "Additional EBS volume IDs"

  value = {
    for name, volume in aws_ebs_volume.this :
    name => volume.id
  }
}