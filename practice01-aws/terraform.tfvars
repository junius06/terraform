vpc_name = "project01"
vpc_cidr_block = "10.0.0.0/16"
vpc_tags = {
  "name" = var.vpc_name
#  "environment" = "dev"
}

image_id = ""
availability_zone_names = ""
ami_id_maps = {
    ap-northeast-2 = {
        amazon_linux2 = ""
        ubuntu_24_04 = ""
    }
}