###################################### 
# EKS Cluster
######################################
resource "aws_eks_cluster" "this" {
  name = "${var.project}-${var.environment}-${local.region_name}-eks"

  role_arn = module.iam_roles.eks_cluster_role_arn # iam.tf  > iam/roles/eks-cluster.tf > iam/roles.outputs.tf

  version = var.eks_version

  vpc_config {
    # EKS Control Plane ENI 전용 Subnet
    subnet_ids = values(
      module.svc_vpc.eks_cluster_private_subnet_ids
    )

    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [ 
    module.iam_roles
   ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-${local.region_name}-eks-cluster"
      type    = "svc"
    }
  )
}


###################################### 
# EKS NodeGroup
######################################
resource "aws_eks_node_group" "this" {
  for_each = var.eks_node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project}-${var.environment}-${each.key}-ng"

  node_role_arn   = module.iam_roles.eks_node_role_arn

  # svc / ops / kpt별 전용 Subnet 사용
  subnet_ids = values(
    module.svc_vpc.eks_node_group_cidrs_groups_ids[each.key]
  )

  ami_type       = "AL2023_ARM_64_STANDARD"
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  labels = {
    role = each.key
  }

  depends_on = [ 
    aws_eks_cluster.this,
    module.iam_roles
   ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-${local.region_name}-eks-ng-${each.key}"
      type    = "svc"
    }
  )
}