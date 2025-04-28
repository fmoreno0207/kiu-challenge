#Este archivo es el que contiene la configuración del proveedor de AWS y la versión de Terraform requerida.
terraform {
  required_version = ">= 1.9.0" 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
  }
}
# # ----------------- AWS -----------------
# # Este bloque define el proveedor de AWS y la región en la que se desplegarán los recursos.
provider "aws" {
  # region = var.region

  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}