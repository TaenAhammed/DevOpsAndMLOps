# Configure the aws provider region and profile
provider "aws" {
  region  = "ap-southeast-1"
  profile = "ido"
}

terraform {
  required_version = "v1.14.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "ido-tfstate"
    key          = "state/dev/ec2/app"
    region       = "ap-southeast-1"
    profile      = "ido"
    use_lockfile = true
    encrypt      = true
  }
}