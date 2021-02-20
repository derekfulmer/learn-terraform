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
