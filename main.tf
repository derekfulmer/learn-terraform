# Create a VPC
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.dev_vpc_cidr_block

  tags = {
    Name = "dev-vpc"
  }
}


module "dev-subnet" {
	source = "./modules/subnet"
	dev_vpc_subnets = var.dev_vpc_subnets
	vpc_id = aws_vpc.dev-vpc.id
}

module "web-server" {
	source = "./modules/webserver"
	dev_vpc_subnets = var.dev_vpc_subnets
	my_ip = var.my_ip
}
