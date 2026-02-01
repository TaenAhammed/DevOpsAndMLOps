module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.vpc_name
  cidr = "10.0.0.0/20"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# Configure security group to allow inbound SSH and HTTP access
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}

# Configure security group to allow documentdb access
resource "aws_security_group" "allow_docdb" {
  name        = "allow_docdb_traffic"
  description = "Allow inbound traffic to DocumentDB"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_web.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
}

  tags = {
    Name = "allow_docdb_traffic"
  }
}

# Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# Output the public subnet IDs
output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

# Output the private subnet IDs
output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnets
}

# Output the security group ID
output "web_security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.allow_web.id
}

# Output the security group ID
output "docdb_security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.allow_docdb.id
}

