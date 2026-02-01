variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}
variable "aws_profile" {
  description = "The AWS CLI profile to use"
  type        = string
  default     = "ido"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "app-vpc"
}