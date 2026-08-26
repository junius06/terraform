module "eks_node" {
  source = "${iam_role_path}"

  role_name = "${var.project}-${var.environment}-${var.region_name}-eks-node-role"

  trusted_service = "ec2.amazonaws.com"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  ]

  # EC2 Instance Profile 미사용
  create_instance_profile = false
}