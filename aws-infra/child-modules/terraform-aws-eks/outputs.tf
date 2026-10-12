######################################
# EKS Clusters
######################################
output "cluster_names" {
  value = {
    for key, cluster in aws_eks_cluster.this :
    key => cluster.name
  }
}

output "cluster_arns" {
  value = {
    for key, cluster in aws_eks_cluster.this :
    key => cluster.arn
  }
}

output "cluster_endpoint" {
  value = {
    for key, cluster in aws_eks_cluster.this :
    key => cluster.endpoint
  }
}

output "cluster_certificate_authorities" {
  value = {
    for key, cluster in aws_eks_cluster.this :
    key => cluster.certificate_authority[0].data
  }
  sensitive = true
}


######################################
# EKS Managed Node Groups
######################################
output "node_group_names" {
  value = {
    for key, node_group in aws_eks_node_group.this :
    key => node_group.node_group_name
  }
}

output "node_group_arns" {
  value = {
    for key, node_group in aws_eks_node_group.this :
    key => node_group.arn
  }
}

output "node_group_ids" {
  value = {
    for key, node_group in aws_eks_node_group.this :
    key => node_group.id
  }
}