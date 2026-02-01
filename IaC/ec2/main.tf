data "aws_vpc" "app-vpc" {
  filter {
    name   = "tag:Name"
    values = ["app-vpc"]
  }
}

data "aws_subnets" "app_subnets" {
  filter {
    name   = "tag:Name"
    values = ["app-vpc-public-*"]
  }
}

data "aws_security_group" "allow_web" {
  filter {
    name   = "tag:Name"
    values = ["allow_web_traffic"]
  }
  vpc_id = data.aws_vpc.app-vpc.id
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-2023*-kernel-*-arm64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["arm64"]
  }
}

resource "aws_key_pair" "app_dev" {
  key_name   = "app-dev-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICd8tFBB7Oma8uy8JCuBweGSgqfYgrzj+Z41c32en98Z taenahammed7@gmail.com"
}

resource "aws_iam_role" "app_dev_role" {
  name = "app-dev-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app_dev_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.app_dev_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.app_dev_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" 
}

resource "aws_iam_instance_profile" "app_dev_instance_profile" {
  name = "app-dev-instance-profile"
  role = aws_iam_role.app_dev_role.name
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.2.0"

  for_each = toset(["dev"])
  name = "ido-app-${each.key}"
  associate_public_ip_address = true
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = "t4g.micro"
  key_name = aws_key_pair.app_dev.key_name
  vpc_security_group_ids = [data.aws_security_group.allow_web.id]
  subnet_id = element(data.aws_subnets.app_subnets.ids, 0)
  iam_instance_profile = aws_iam_instance_profile.app_dev_instance_profile.name
}
