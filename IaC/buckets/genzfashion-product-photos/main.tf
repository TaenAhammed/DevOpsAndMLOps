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
  # Configuration options
}