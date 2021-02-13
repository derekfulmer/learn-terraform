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
  description = "From where you may SSH"
}
# Create a VPC
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.dev_vpc_cidr_block

  tags = {
    Name = "dev-vpc"
  }
}

# Create a public subnet in one AZ
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

# Launch an EC2 instance, with Security Group rules for HTTP/S and SSH
resource "aws_instance" "foo" {
  ami           = "ami-0ff8a91507f77f867"
  instance_type = "t2.micro"
  key_name      = "value"
  depends_on    = [aws_internet_gateway.dev-vpc-igw]
}

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


