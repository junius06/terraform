# ============================================================
# Bastion
# ============================================================
output "bastion_role_name" {
  value = module.bastion.role_name
}

output "bastion_role_arn" {
  value = module.bastion.role_arn
}

output "bastion_instance_profile_name" {
  value = module.bastion.instance_profile_name
}


# ============================================================
# EKS Cluster
# ============================================================
output "eks_cluster_role_name" {
  value = module.eks_cluster.role_name
}

output "eks_cluster_role_arn" {
  value = module.eks_cluster.role_arn
}


# ============================================================
# EKS Node
# ============================================================
output "eks_node_role_name" {
  value = module.eks_node.role_name
}

output "eks_node_role_arn" {
  value = module.eks_node.role_arn
}


# ============================================================
# RDS Monitoring
# ============================================================
output "rds_monitoring_role_name" {
  value = module.rds_monitoring.role_name
}

output "rds_monitoring_role_arn" {
  value = module.rds_monitoring.role_arn
}