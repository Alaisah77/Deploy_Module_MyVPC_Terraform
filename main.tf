# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets_cidr[0]  # Index 0 for the first subnet (public)
  availability_zone = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

# Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets_cidr[1]  # Index 1 for the second subnet (public)
  availability_zone = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Private Subnet
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets_cidr[2]  # Index 2 for the third subnet (private)
  availability_zone = var.availability_zones[0]  # Use availability zone 1 for the private subnet
  tags = {
    Name = "private-subnet-1"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnets with the route table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway for Private Subnet
resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private-route-table"
  }
}

# Associate private subnet with the route table
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}


# Create 5 EC2 instances in the public subnets
resource "aws_instance" "public" {
  count = 5

  ami                    = var.ami_id  # Provide the latest Ubuntu/Debian AMI ID
  instance_type          = "t2.micro"
  subnet_id              = element([aws_subnet.public_1.id, aws_subnet.public_2.id], count.index % 2)
  associate_public_ip_address = true
  key_name               = var.key_name
  user_data              =  <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "Great assistance from GPT" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF

  tags = {
    Name = "ankeambom-app-${count.index}"
  }
}

# Create 2 EC2 instances in the private subnet as DB instances
resource "aws_instance" "private_db" {
  count = 2

  ami                    = var.ami_id  # Provide the same Ubuntu/Debian AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_1.id
  associate_public_ip_address = false  # No public IP for private subnet
  key_name               = var.key_name
  user_data              = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "Great assistance from GPT" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF

  tags = {
    Name = "ankeambom-db-instance-${count.index}"
  }
}


# Security Group for Public EC2 Instances (allow HTTP and SSH)
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (restrict to your IP for security)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

# Security Group for Private EC2 DB Instances (allow internal traffic)
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow DB traffic from the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-db-sg"
  }
}
