locals {
  # IGW 이름 설정 => endswith 함수로 문자열 끝의 "vpc"을 찾아 replace 함수로 치환
  igw_name = endswith(var.vpc_name, "vpc") ? replace(var.vpc_name, "vpc", "igw") : "VPC YAML 파일명을 네이밍 룰에 맞게 변경하세요!"

  # VPC Flow Log 이름 설정
  vpc_flow_log_name = endswith(var.vpc_name, "vpc") ? replace(var.vpc_name, "vpc", "vpcflow") : "VPC YAML 파일명을 네이밍 룰에 맞게 변경하세요!"

  # 서브넷별 Routing Table 이름 설정 => 서브넷 존재할 때, '-'를 기준으로 서브넷명 문자열을 분리한 후, rtb 문자열 추가하고 문자열 조인 join
  # dev-fmm-uw2-ext-pub-a => dev-fmm-uw2-rtb-ext-pub-a
  pub_rtb_name = var.public_subnet != null ? { for key, value in var.public_subnet : replace(value.tags.Name, "sbn", "rtb") => value.tags.Name } : {}
  pri_rtb_name = var.private_subnet != null ? { for key, value in var.private_subnet : replace(value.tags.Name, "sbn", "rtb") => value.tags.Name } : {}

  # NAT를 생성할 퍼블릭 서브넷이 존재할 경우, 서브넷명의 '-'를 기준으로 서브넷명 문자열을 분리한 후, eip 문자열 추가하고 문자열 조인 join
  # ex) dev-fmm-uw2-eip-ext-pub-a
  public_nat_eip_name = [for key, value in var.public_nat_gateway_subnets : replace(value, "sbn", "eip") if var.public_nat_gateway_subnets != null && var.public_subnet != null]

  # 생성된 서브넷명 기준으로 Key(NAT Name), Value(EIP, Subnet ID) 형태로 문자열 재조립
  public_nat_name = local.public_nat_eip_name != null ? { for subnet_name, subnet_attribute in aws_subnet.public : replace(subnet_name, "sbn", "nat") => {
    "subnet_id" = aws_subnet.public[subnet_name].id,
    "eip_id" = aws_eip.nat[replace(subnet_name, "sbn", "eip")].id }
    if contains(var.public_nat_gateway_subnets, subnet_name) # public_nat_gateway_subnets 에 포함된 서브넷만 문자열 생성
  } : null

  # public_nat_name 출력 예시 
  #"dev-fmm-uw2-nat-ext-pub-a" = {
  #   "eip_id" = "eipalloc-08206ea310a244706"
  #   "subnet_id" = "subnet-0c95c02b317973a6f"
  # }
  #"dev-fmm-uw2-nat-ext-pub-b" = {
  #   "eip_id" = "eipalloc-0dda99746a436d790"
  #   "subnet_id" = "subnet-019df5ce178bfc758"
  # }
}

################################################################################
# VPC
################################################################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name = var.vpc_name
  }
}

################################################################################
# VPC Flow Log
################################################################################
resource "aws_flow_log" "this" {
  for_each = var.vpc_flow_log_s3_name != "" ? toset([local.vpc_flow_log_name]) : toset([])

  vpc_id                   = aws_vpc.this.id
  traffic_type             = "ALL"
  max_aggregation_interval = "60"

  log_destination_type = "s3"
  log_destination      = "arn:aws:s3:::${var.vpc_flow_log_s3_name}"
  log_format           = "$${account-id} $${action} $${az-id} $${bytes} $${dstaddr} $${dstport} $${end} $${flow-direction} $${instance-id} $${interface-id} $${log-status} $${packets} $${pkt-dst-aws-service} $${pkt-dstaddr} $${pkt-src-aws-service} $${pkt-srcaddr} $${protocol} $${region} $${srcaddr} $${srcport} $${start} $${sublocation-id} $${sublocation-type} $${subnet-id} $${tcp-flags} $${traffic-path} $${type} $${version} $${vpc-id}"

  destination_options {
    file_format                = "parquet"
    hive_compatible_partitions = false
    per_hour_partition         = false
  }
  tags = {
    Name = local.vpc_flow_log_name
  }
}

################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "this" {
  for_each = length(aws_subnet.public) > 0 ? toset([local.igw_name]) : toset([]) # public subnet 존재 여부에 따라 IGW 생성 조건

  vpc_id = aws_vpc.this.id
  tags = {
    Name = local.igw_name
  }
}

################################################################################
# Public Subnet
################################################################################
resource "aws_subnet" "public" {
  for_each = { for k, v in var.public_subnet : v.tags.Name => v if var.public_subnet != null } # public_subnet을 선언하지 않으면 null일 수 있으므로 조건 처리

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.subnet_cidr
  availability_zone       = "${var.region}${substr(each.key, -1, 1)}" # 서브넷 끝 자리 a,c를 기준으로 존 설정
  map_public_ip_on_launch = true
  tags                    = each.value.tags
}

###############################################################################
# Private Subnet
###############################################################################
resource "aws_subnet" "private" {
  for_each = { for k, v in var.private_subnet : v.tags.Name => v if var.private_subnet != null }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.subnet_cidr
  availability_zone = "${var.region}${substr(each.key, -1, 1)}" # 서브넷 끝 자리 a,c를 기준으로 존 설정
  tags              = each.value.tags
}

################################################################################
# Publiс Routetable
################################################################################
resource "aws_route_table" "public" {
  for_each = local.pub_rtb_name != null ? local.pub_rtb_name : {}

  vpc_id = aws_vpc.this.id
  tags = {
    Name = each.key
  }
}
resource "aws_route_table_association" "public" {
  for_each = local.pub_rtb_name != null ? local.pub_rtb_name : {}

  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route" "public_internet_gateway" {
  for_each = aws_route_table.public

  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[local.igw_name].id

  timeouts {
    create = "2m"
  }
}

################################################################################
# Private Routetable
################################################################################
resource "aws_route_table" "private" {
  for_each = local.pri_rtb_name != null ? local.pri_rtb_name : {}

  vpc_id = aws_vpc.this.id
  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "private" {
  for_each = local.pri_rtb_name != null ? local.pri_rtb_name : {}

  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private[each.key].id
}

################################################################################
# EIP
################################################################################
resource "aws_eip" "nat" {
  for_each = toset(local.public_nat_eip_name) # toset([])을 사용하여 중복값 제거

  domain = "vpc"

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = each.key
  }
}

################################################################################
# NAT Gateway
################################################################################
resource "aws_nat_gateway" "public" {
  for_each = local.public_nat_name

  allocation_id = each.value.eip_id
  subnet_id     = each.value.subnet_id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = each.key
  }
}