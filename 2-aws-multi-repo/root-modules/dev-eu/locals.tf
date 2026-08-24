locals {
  region_map = {
    "eu-west-1" = {
      name = "ireland"
      code = "ew1"
    }

    "us-west-2" = {
      name = "oregon"
      code = "uw2"
    }

    "ap-northeast-2" = {
      name = "seoul"
      code = "an2"
    }
  }

  region_name = local.region_map[var.aws_region].name
  region_code = local.region_map[var.aws_region].code
}