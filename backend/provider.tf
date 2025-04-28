terraform {
  required_version = ">= 1.9.0" 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
  }
}
provider "aws" {
  # region = var.region

  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}