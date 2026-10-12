######################################
# EKS Managed Node Groups
######################################
# 중첩된 node_group을 for_each에서 사용할 수 있도록 평탄화
locals {
  node_groups = merge(
    {},
    [
      for cluster_key, cluster in var.cluster : {
        for node_group_key, node_group in cluster.node_groups :
        "${cluster_key}/${node_group_key}" => merge(
          node_group,
          {
            cluster_key    = cluster_key
            node_group_key = node_group_key
          }
        )
      }
    ]...
  )
}