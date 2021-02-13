provider "aws"{
    region = "us-east-1"
    } 

variable "dev_vpc_cidr_block" {
    description = "Subnet CIDR block for the dev VPC"
}

variable "dev_vpc_subnets" {
    description = "A list of subnet strings to define VPC subnets"
    type = list(string)
}

# Create a VPC
resource "aws_vpc" "dev-vpc" {
    cidr_block = var.dev_vpc_cidr_block

    tags = {
      Name = "dev-vpc"
    }
}
  
# Create a public subnet in one AZ
resource "aws_subnet" "dev-subnet-public" {
    vpc_id = "aws_vpc.dev-vpc.id"
    cidr_block = var.dev_vpc_subnets[0]
    availability_zone = "us-east-1a"
}

resource "aws_route_table" "dev-rtb-1" {
    vpc_id = "aws_vpc.dev-vpc.id"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dev-vpc-igw.id
    }
    tags = {
      Name = "dev-rtb-1"
    }
}

# Launch an IGW
resource "aws_internet_gateway" "dev-vpc-igw" {
    vpc_id = "aws_vpc.dev-vpc.id"

    tags = {
      Name = "dev-igw"
    }
  
}

# Create an SSH keypair to use with the instance

# Launch an EC2 instance, with Security Group rules for HTTP/S and SSH
resource "aws_instance" "foo" {
    ami = "ami-0ff8a91507f77f867"
    instance_type = "t2.micro"
    key_name = "value"
    depends_on = [aws_internet_gateway.dev-vpc-igw]
}


# Deploy nginx Docker container


