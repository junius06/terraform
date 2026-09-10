######################################
# VPC Flow log
######################################
resource "aws_flow_log" "flow_log" {
  count = var.enable_vpc_flow_log ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = var.vpc_flow_log_destination_arn

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-flow-log"
    }
  )
}