terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.23.0"
    }
  }
  required_version = "v1.14.0"

  backend "s3" {
    bucket       = "devops-course-tfstate-demo"
    key          = "dev/networking/vpc"
    region       = "ap-southeast-1"
    profile      = "ido"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "ido"
}