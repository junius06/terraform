###################################### 
# VPC
######################################
output "vpc_ids" {
  description = "VPC IDs"

  value = {
    for key, vpc in module.vpc :
    key => vpc.vpc_id
  }
}


###################################### 
# VPC Peering
######################################
output "vpc_peering_ids" {
  description = "VPC Peering Connection IDs"

  value = {
    for key, peering in module.vpc_peering :
    key => peering.id
  }
}