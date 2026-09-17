variable "context" {
  description = "Common resource context"

  type = object({
    project     = string
    environment = string
    region_name = string
    region      = string
  })
}

variable "common_tags" {
  description = "Common Tags"
  type    = map(string)
  default = {}
}

######################################
# Requester VPC
######################################
variable "requester_vpc_id" {
  description = "VPC ID of the requester(Source) VPC"
  type        = string
}

variable "requester_vpc_alias" {
  description = "Logical Name og the VPC peering connection"
  type        = string
}

######################################
# Accepter VPC & Region
######################################
variable "accepter_vpc_id" {
  description = "VPC ID of the accepter(Destination) VPC"
  type        = string

  # VPC ID 유효성 검사
  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.accepter_vpc_id))
    error_message = "accepter_vpc_id must be a valid VPC ID."
  }
}

variable "accepter_vpc_alias" {
  description = "VPC alias of the accepter(Destination) VPC"
  type        = string
}

variable "accepter_region" {
  description = "Region of the accepter VPC. Null means same region as requester."
  type        = string
  default     = null

  validation {
    condition = (
      var.accepter_region == null ||
      contains(
        [
          "eu-west-1",
          "us-west-2",
          "ap-southeast-1"
        ],
        var.accepter_region
      )
    )
    error_message = "For the accepter_region, You must input one of the following: 'eu-west-1', 'us-west-2', 'ap-southeast-1'."
  }
}

######################################
# Cross Account (Optional ㅡ default: disable)
######################################
variable "enable_cross_account" {
  description = "Whether the accepter VPC is in a diffrent AWS Account"
  type        = bool
  default     = false
}

variable "accepter_account_id" {
  description = "AWS Account ID of the accepter VPC"
  type = string
  default = null

  # enable_cross_account = true/false 에 따른 Account ID 입력 검증
  validation {
    condition = (
    (
      var.enable_cross_account &&       # enable_cross_account = true  → accepter_account_id 필수 입력
      var.accepter_account_id != null
    )
    ||
    (
      !var.enable_cross_account &&      # enable_cross_account = false → accepter_account_id는 null
      var.accepter_account_id == null
    )
    )
    error_message = "accepter_account_id must be provided only when enable_cross_account is true."
  }

  # AWS Account ID 형식 검증
  validation {
    condition = (
      var.accepter_account_id == null ||                    # null 허용
      can(regex("^[0-9]{12}$", var.accepter_account_id))    # 값이 입력된 경우 숫자로만 구성된 정확히 12자리인지 검증
    )
    error_message = "accepter_account_id of AWS Account ID is invalid"
  }
}

######################################
# OPTIONS
######################################
variable "auto_accept" {
  description = "Automatically accept the VPC peering connection"
  type        = bool
  default     = true
}

# 서로 다른 VPC의 Private IP로 DNS Query 조회 여부
variable "allow_remote_vpc_dns_resolution" {
  description = "Allow DNS resolution from the remote VPC"
  type        = bool
  default     = true
}