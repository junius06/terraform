module "eks_cluster" {
  source = "${iam_role_path}"

  role_name = "${var.project}-${var.environment}-${var.region_name}-eks-cluster-role"

  trusted_service = "eks.amazonaws.com"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]

  # EC2 Instance Profile 미사용
  create_instance_profile = false
}