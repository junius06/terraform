output "main_vpc_id" {
  description = "MAIN VPC ID"
  value       = module.main_vpc.vpc_id
}

output "main_vpc_cidr" {
  description = "MAIN VPC CIDR"
  value       = module.main_vpc.vpc_cidr
}