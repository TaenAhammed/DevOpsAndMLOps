data "aws_vpc" "app-vpc" {
  filter {
    name   = "tag:Name"
    values = ["app-vpc"]
  }
}

data "aws_subnets" "app_subnets" {
  filter {
    name   = "tag:Name"
    values = ["app-vpc-private-*"]
  }
}

data "aws_security_group" "allow_docdb" {
  filter {
    name   = "tag:Name"
    values = ["allow_docdb_traffic"]
  }
  vpc_id = data.aws_vpc.app-vpc.id
}

resource "random_password" "ido_docdb_password" {
  length           = 16
  special          = false
  override_special = "_%@"
}

resource "aws_ssm_parameter" "ido_docdb_password" {
  name        = "/ido/dev/docdb/password"
  description = "Password for the DocumentDB admin user"
  type        = "SecureString"
  value       = random_password.ido_docdb_password.result
}

resource "aws_docdb_subnet_group" "docdb_serverless_dev" {
  name       = "ido-docdb-serverless-subnet-group-dev"
  subnet_ids = data.aws_subnets.app_subnets.ids
  tags = {
    Name = "ido-docdb-serverless-subnet-group-dev"
  }
}

resource "aws_docdb_cluster_parameter_group" "docdb_serverless_dev" {
  name        = "ido-docdb-serverless-parameter-group-dev"
  family      = "docdb5.0"
  description = "Parameter group for ido DocumentDB serverless dev cluster"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_cluster" "ido_docdb_serverless_dev" {
  storage_encrypted               = true
  cluster_identifier              = "ido-docdb-serverless-dev"
  engine                          = "docdb"
  engine_version                  = "5.0.0"
  master_username                 = "root"
  master_password                 = aws_ssm_parameter.ido_docdb_password.value
  vpc_security_group_ids          = [data.aws_security_group.allow_docdb.id]
  db_subnet_group_name            = aws_docdb_subnet_group.docdb_serverless_dev.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.docdb_serverless_dev.name
  skip_final_snapshot             = true
  preferred_backup_window         = "00:00-02:00"
  preferred_maintenance_window    = "fri:03:00-fri:04:00"

  serverless_v2_scaling_configuration {
    min_capacity = 0.5 # DCU
    max_capacity = 1.0 # DCU
  }

  tags = {
    Name = "ido-docdb-serverless-dev"
  }
}

resource "aws_docdb_cluster_instance" "docdb_serverless_dev" {
  cluster_identifier = aws_docdb_cluster.ido_docdb_serverless_dev.id
  identifier         = "dev-docdb-serverless-instance-1"
  instance_class     = "db.serverless"
  apply_immediately  = true
  availability_zone  = "ap-southeast-1a"
}

output "docdb_cluster_endpoint" {
  description = "The endpoint of the DocumentDB cluster"
  value       = aws_docdb_cluster.ido_docdb_serverless_dev.endpoint
}

output "docdb_cluster_id" {
  description = "The ID of the DocumentDB cluster"
  value       = aws_docdb_cluster.ido_docdb_serverless_dev.id
}