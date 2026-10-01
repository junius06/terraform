######################################
# EC2
######################################
resource "aws_instance" "this" {
  for_each = var.instances

  ami           = each.value.ami_id
  instance_type = each.value.instance_type

  key_name             = each.value.key_name
  iam_instance_profile = each.value.iam_instance_profile

  monitoring = each.value.monitoring

  user_data = each.value.user_data

  #### Network ####
  subnet_id = each.value.subnet_id

  vpc_security_group_ids = each.value.security_group_ids

  associate_public_ip_address = each.value.associate_public_ip_address

  #### Root Volume ####
  root_block_device {
    volume_type = each.value.root_volume.volume_type
    volume_size = each.value.root_volume.volume_size

    iops = (
      contains(
        ["gp3", "io2"],
        each.value.root_volume.volume_type
      )
      ? each.value.root_volume.iops
      : null
    )

    throughput = (
      each.value.root_volume.volume_type == "gp3"
      ? each.value.root_volume.throughput
      : null
    )

    encrypted  = each.value.root_volume.encrypted
    kms_key_id = each.value.root_volume.kms_key_id

    delete_on_termination = (
      each.value.root_volume.delete_on_termination
    )

    tags = merge(
      var.common_tags,
      each.value.tags,
      {
        Name = "${each.key}-ebs-root"
      }
    )
  }

  #### EC2 Tags ####
  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name        = each.key
      IPA_TAGS    = "${each.key}, app-account:${var.ipa_user}"
    }
  )
}


######################################
# Additional EBS Volume
######################################
resource "aws_ebs_volume" "this" {
  for_each = local.ebs_volumes

  availability_zone = aws_instance.this[
    each.value.instance_name
  ].availability_zone

  type = each.value.volume_type
  size = each.value.volume_size
  
  iops = (
    contains(
      ["gp3", "io2"],
      each.value.volume_type
    )
    ? each.value.iops
    : null
  )

  throughput = (
    each.value.volume_type == "gp3"
    ? each.value.throughput
    : null
  )

  encrypted  = each.value.encrypted
  kms_key_id = each.value.kms_key_id

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = "${each.value.instance_name}-ebs-${each.value.volume_name}"
    }
  )
}


######################################
# EBS Volume Attachment
######################################
resource "aws_volume_attachment" "this" {
  for_each = local.ebs_volumes

  device_name = each.value.device_name

  volume_id = aws_ebs_volume.this[
    each.key
  ].id

  instance_id = aws_instance.this[
    each.value.instance_name
  ].id

  stop_instance_before_detaching = each.value.stop_instance_before_detaching
}


######################################
# Elastic IP
######################################
resource "aws_eip" "this" {
  for_each = local.eip_instances

  domain = "vpc"

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = "${each.value.instance_name}-eip"
    }
  )
}


######################################
# Elastic IP Association
######################################
resource "aws_eip_association" "this" {
  for_each = local.eip_instances

  instance_id = aws_instance.this[
    each.key
  ].id

  allocation_id = aws_eip.this[
    each.key
  ].id
}