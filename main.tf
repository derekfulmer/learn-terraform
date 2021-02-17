provider "aws" {
  region = "us-east-1"
}

variable "dev_vpc_cidr_block" {
  description = "Subnet CIDR block for the dev VPC"
}

variable "dev_vpc_subnets" {
  description = "A list of subnet strings to define VPC subnets"
  type        = list(string)
}

variable "my_ip" {
  description = "My IP"
}

# Create a VPC
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.dev_vpc_cidr_block

  tags = {
    Name = "dev-vpc"
  }
}

# Create a subnet in one AZ
resource "aws_subnet" "dev-subnet" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.dev_vpc_subnets[0]
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "dev-rtb-1" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-vpc-igw.id
  }
  tags = {
    Name = "dev-rtb-1"
  }
}

resource "aws_route_table_association" "dev-rtb-subnet-assoc" {
  subnet_id      = aws_subnet.dev-subnet.id
  route_table_id = aws_route_table.dev-rtb-1.id

}

# Launch an IGW
resource "aws_internet_gateway" "dev-vpc-igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-igw"
  }

}

# Create an SSH keypair to use with the instance

data "aws_ami" "latest-amazon-linux-image"{
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch an EC2 instance, with Security Group rules for HTTP/S and SSH
resource "aws_instance" "web-server-1" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.dev-subnet.id
  vpc_security_group_ids = [aws_security_group.dev-sg.id] 
  availability_zone = "us-east-1a"
  key_name      = "learn-tf"

  associate_public_ip_address = true

  depends_on    = [aws_internet_gateway.dev-vpc-igw]

  tags = {
    Name = "web-server-1"
  }
}

# Create an output of the public IP address of the EC2 instance 

resource "aws_security_group" "dev-sg" {
  name   = "dev-sg"
  vpc_id = aws_vpc.dev-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 8080
    to_port         = 0
    protocol        = "-1"
    prefix_list_ids = []
  }

  tags = {
    Name = "dev-sg"
  }
}

# Deploy nginx Docker container


