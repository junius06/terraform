resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2023_arm64.id   # data.tf 에서 정의한 데이터 가져오기
  instance_type = var.bastion_instance_type

  subnet_id = module.mgmt_vpc.public_subnet_ids["a"]

  iam_instance_profile = module.iam_roles.bastion_instance_profile_name   # iam/roles/outputs.tf 에서 가져온 변수명

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-${local.region_name}-bastion"
      type    = "mgmt"
    }
  )
}