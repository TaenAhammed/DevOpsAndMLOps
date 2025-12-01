terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.23.0"
    }
  }
  required_version = "v1.14.0"
}

provider "aws" {
  region = "ap-southeast-1"
  profile = "ido"
}

resource "aws_s3_bucket" "genzfashion-product-photos" {
  bucket = "genzfashion-product-photos"

  tags = {
    Name        = "genzfashion-product-photos"
    Environment = "Dev"
  }
}