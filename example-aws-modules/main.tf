provider "aws" {
  region = "ap-northeast-2"

  shared_config_files = [ "~/.aws/conf" ]
  shared_credentials_files = [ "~/.aws/creds" ]
  profile = "myprofile"
  # access_key = "~/.aws/access_key" #"${ secret.aws_access_key }"
  # secret_key = "~/.aws/secret_key" #"${ secret.aws_secret_key }"

  default_tags {
    tags = {
      Name = "credentials"
    }
  }
}

module "vpc" {
  source = "./modules/01_vpc"
  version = "3.18.1"

  vpc_name = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block

  igw_name = var.igw_name

  environment = var.environment
}

module "ec2_instances" {
  source = "./modules/02_ec2"
  version = "3.18.1"

  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  instance_type = var.instance_type
  ami_id = var.ami_id
}