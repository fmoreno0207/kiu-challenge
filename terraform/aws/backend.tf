# Resource to create the S3 bucket where the Terraform state will be stored

resource "aws_s3_bucket" "terraform_state" {
    bucket = "${var.project}-${var.environment_name}-tf-state-bucket"
    force_destroy = true  # Cambiar a false para evitar eliminar accidentalmente el bucket (True para producción)
}

#Resource to enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
    bucket = aws_s3_bucket.terraform_state.id  # Asociamos el recurso de versionado con el bucket S3 creado

    versioning_configuration {
        status = "Enabled"  # Habilita el versionado en el bucket de S3
    }
}

#This faile contains the configuration for the S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id  # Asociar con el bucket creado previamente

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Algoritmo de cifrado AES-256
    }
  }
}

#This file contains the configuration for the DynamoDB table

resource "aws_dynamodb_table" "terraform_locks" {
    name = "${var.project}-tf-state-dynamo-db-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}