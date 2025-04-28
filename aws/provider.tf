# ----------------- Terraform -----------------
# Este archivo contiene la configuración del proveedor de AWS y Helm
# y la configuración del backend de S3 para almacenar el estado de Terraform.
terraform {
  required_version = ">= 1.9.0" 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }

  #Creación del backend de S3 para almacenar el estado de Terraform
  #El bucket de S3 y la tabla de DynamoDB deben existir antes de ejecutar el primer plan
  backend "s3" {
    bucket         = "kiu-dev-tf-state-bucket"          
    dynamodb_table = "kiu-dev-tf-state-dynamo-db-table" 
    key            = "terraform.tfstate"
    region         = "us-east-1" 
    encrypt        = true
  }
}

# ----------------- AWS -----------------

provider "aws" {
  # region = var.region
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}



# ----------------- Helm -----------------

data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.cluster.id
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)

    token = data.aws_eks_cluster_auth.default.token
  }
}
