bucket       = "s3-uw2-resource-parser-01"
region       = "eu-west-1" # bucket이 존재하는 region으로 설정

key          = "terraform.tfstate"
encrypt      = true
use_lockfile = true