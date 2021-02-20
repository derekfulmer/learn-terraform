data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web-server-1" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = "t2.micro"

  subnet_id              = var.dev_vpc_subnets[0]
  vpc_security_group_ids = aws_security_group.dev-sg.id
  availability_zone      = "us-east-1a"
  key_name               = "learn-tf"

  associate_public_ip_address = true

  user_data = file("setup.sh")

  tags = {
    Name = "web-server-1"
  }
}

resource "aws_security_group" "dev-sg" {
  name   = "dev-sg"
  vpc_id = var.vpc_id 

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
