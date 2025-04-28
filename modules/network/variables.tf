variable "region" {
  description = "AWS region to deploy resources"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "vpc_name" {
  description = "Name for the VPC"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
}

variable "subnet_public_name" {
  description = "Name for the public subnet"
}

variable "subnet_private_name" {
  description = "Name for the private subnet"
}
