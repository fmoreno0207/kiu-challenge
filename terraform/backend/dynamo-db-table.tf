#recurso para crear la tabla DynamoDB para el bloqueo de Terraform
resource "aws_dynamodb_table" "terraform_locks" {
    name = "${var.project}-${var.environment_name}-tf-state-dynamo-db-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}

#Si la tabla ya existe, puedes importarla a tu estado de Terraform
#terraform import aws_dynamodb_table.terraform_locks kiu-dev-tf-state-dynamo-db-table