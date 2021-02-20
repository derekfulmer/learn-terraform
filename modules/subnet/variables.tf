variable "dev_vpc_subnets" {
  description = "A list of subnet strings to define VPC subnets"
  type        = list(string)
}

variable "vpc_id" {
  default = "The ID of the VPC"  
}