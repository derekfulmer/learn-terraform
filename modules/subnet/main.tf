resource "aws_subnet" "dev-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.dev_vpc_subnets[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "dev-subnet-1"
  }
}

resource "aws_route_table" "dev-rtb-1" {
  vpc_id = var.vpc_id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-vpc-igw.id
  }

  tags = {
    Name = "dev-rtb-1"
  }
}

resource "aws_route_table_association" "dev-rtb-subnet-assoc" {
  subnet_id      = var.dev_vpc_subnets[0]
  route_table_id = aws_route_table.dev-rtb-1.id

}

# Launch an IGW
resource "aws_internet_gateway" "dev-vpc-igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "dev-igw"
  }

}