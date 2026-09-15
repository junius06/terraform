module "bastion" {
  source = "${iam_role_path}"

  role_name = "${var.project}-${var.environment}-${var.region_name}-bastion-role"

  trusted_service = "ec2.amazonaws.com"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  # EC2 Instance Profile 사용
  create_instance_profile = true
}