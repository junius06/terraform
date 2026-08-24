module "vpc" {
  source = "../../modules/vpc"

  env = "dev"
}

module "ec2" {
  source = "../../modules/ec2"

  env = "dev"
}