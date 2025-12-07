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
    key          = "dev/storage/s3/genzfashion-product-photos"
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

resource "aws_s3_bucket" "genzfashion-product-photos" {
  bucket = "genzfashion-product-photos"

  tags = {
    Name        = "genzfashion-product-photos"
    Environment = "Dev"
  }
}

# add bucket policy to move objects to Glacier after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "genzfashion-product-photos-lifecycle" {
  bucket = aws_s3_bucket.genzfashion-product-photos.id

  rule {
    id     = "move-to-glacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER" 
    }
  }
}