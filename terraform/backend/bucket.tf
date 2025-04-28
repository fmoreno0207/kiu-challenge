# Recurso para crear el bucket S3 donde se almacenará el estado de Terraform
resource "aws_s3_bucket" "terraform_state" {
    bucket = "${var.project}-${var.environment_name}-tf-state-bucket"
    force_destroy = true  # Cambiar a false para evitar eliminar accidentalmente el bucket (True para producción)
}

# Recurso para habilitar el versionado en el bucket S3
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
    bucket = aws_s3_bucket.terraform_state.id  # Asociamos el recurso de versionado con el bucket S3 creado

    versioning_configuration {
        status = "Enabled"  # Habilita el versionado en el bucket de S3
    }
}

# Configuración de cifrado para el bucket S3
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id  # Asociar con el bucket creado previamente

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Algoritmo de cifrado AES-256
    }
  }
}


#si el bucket de S3 ya existe, se puede usar el siguiente bloque para evitar la creación de un nuevo bucket
#terraform import aws_s3_bucket.terraform_state kiu-dev-tf-state-bucket