# Create a VPC

resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16" # VPC IP Range: 10.0.0.0 - 10.0.255.255

  tags = {
    Name = "main-vpc"
  }
}

# Create an Internet Gateway

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "main-igw"
  }
}

# Create a custom route table
resource "aws_route_table" "main-route-table" {
  vpc_id = aws_vpc.main-vpc.id

  # Create a route to allow internet access
  route {
    cidr_block = "0.0.0.0/0" # Route for all IPv4 traffic
    gateway_id = aws_internet_gateway.main-igw.id
  }

  route {
    ipv6_cidr_block = "::/0" # Route for all IPv6 traffic
    gateway_id      = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Create a public subnet
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.1.0/24" # Subnet IP Range: 10.0.1.0 - 10.0.1.255
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true
}

# Associate the public subnet with the custom route table
resource "aws_route_table_association" "public-subnet-1-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.main-route-table.id
}

# Security Group to allow inbound SSH and HTTP access
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_web_traffic"
  }
}

resource "aws_key_pair" "local_ssh" {
  key_name = "ido"
  public_key = file("~/.ssh/ido.pub")
}

resource "aws_instance" "genz-fashion-dev" {
  ami = "ami-00d8fc944fb171e29" # Ubuntu Server 24.04 LTS 64-bit x86 (ami-00d8fc944fb171e29) in ap-southeast-1
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  key_name = aws_key_pair.local_ssh.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              EOF
  tags = {
    Name = "genz-fashion-dev"
  }
}