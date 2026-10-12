######################################
# EKS Cluster
######################################
resource "aws_eks_cluster" "this" {
  for_each = var.cluster

  name = "${var.context.naming_rule}-${each.key}-eks"

  version  = each.value.version
  role_arn = each.value.role_arn
  
  enabled_cluster_log_types = each.value.enabled_cluster_log_types
  deletion_protection       = each.value.deletion_protection

  access_config {
    authentication_mode = each.value.authentication_mode

    bootstrap_cluster_creator_admin_permissions = (
      each.value.bootstrap_cluster_creator_admin_permissions
    )
  }

  vpc_config {
    subnet_ids         = each.value.subnet_ids
    security_group_ids = each.value.security_group_ids

    endpoint_private_access = each.value.endpoint_private_access
    endpoint_public_access  = each.value.endpoint_public_access

    public_access_cidrs     = (
      each.value.public_access_cidrs
      ? each.value.public_access_cidrs
      : null
    )
  }

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = "${var.context.naming_rule}-${each.key}-eks"
    }
  )
}


######################################
# EKS Managed Node Groups
######################################
resource "aws_eks_node_group" "this" {
  for_each = local.node_groups

  cluster_name    = aws_eks_cluster.this[
    each.value.cluster_key
  ].name

  node_group_name = (
    "${var.context.naming_rule}-${each.value.cluster_key}-eks-${each.value.node_group_key}-ng"
  )

  node_role_arn = each.value.node_role_arn

  subnet_ids = each.value.subnet_ids

  instance_types = each.value.instance_types
  ami_type       = each.value.ami_type
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  update_config {
    max_unavailable = each.value.max_unavailable
  }

  labels = each.value.labels

  dynamic "taint" {
    for_each = each.value.taints

    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = "${var.context.naming_rule}-${each.value.cluster_key}-eks-${each.value.node_group_key}-ng"
    }
  )
}