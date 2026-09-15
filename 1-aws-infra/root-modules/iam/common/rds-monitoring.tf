module "rds_monitoring" {
  source = "${iam_role_path}"

  role_name = "${var.project}-${var.environment}-${var.region_name}-rds-monitoring-role"

  trusted_service = "monitoring.rds.amazonaws.com"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  ]
  
  # EC2 Instance Profile 미사용
  create_instance_profile = false
}