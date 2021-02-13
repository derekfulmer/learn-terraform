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
}

# Launch an IGW
resource "aws_internet_gateway" "dev-vpc-igw" {
    vpc_id = "aws_vpc.dev-vpc.id"

    tags = {
      Name = "dev-igw"
    }
  
}
# Launch an EC2 instance, with Security Group rules for HTTP/S and SSH
resource "aws_instance" "foo" {
    ami = "ami-0ff8a91507f77f867"
    instance_type = "t2.micro"
}
# Deploy nginx Docker container


