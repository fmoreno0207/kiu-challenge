# ID de la VPC creada
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# ID de la Subnet Pública creada
output "public_subnet_id" {
  description = "ID of the Public Subnet"
  value       = aws_subnet.public.id
}

# ID de la Subnet Privada creada
output "private_subnet_id" {
  description = "ID of the Private Subnet"
  value       = aws_subnet.private.id
}

# ID del Internet Gateway creado
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

# ID de la Public Route Table creada
output "public_route_table_id" {
  description = "ID of the Public Route Table"
  value       = aws_route_table.public.id
}
