# Configura el proveedor de AWS
provider "aws" {
  region = var.region
}

# Crea la VPC principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Crea la Subnet Pública (permite acceso a Internet)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_public_name
  }
}

# Crea la Subnet Privada (sin acceso directo a Internet)
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = var.subnet_private_name
  }
}

# Crea el Internet Gateway (salida a Internet para recursos en subnets públicas)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Crea la Route Table Pública (rutas para la subnet pública hacia Internet)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Asocia la Route Table Pública con la Subnet Pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Crea Elastic IP para NAT Gateway
resource "aws_eip" "nat" {
#  vpc = true

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# Crea NAT Gateway en la subred pública
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

# Actualiza la tabla de rutas de la subred privada para usar el NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


# Security Group for ALB (Load Balancer)
# Este SG permite tráfico HTTP (puerto 80) desde internet para que el ALB reciba tráfico público.
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Acceso HTTPS
  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  #Acceso a la consola de administración de AWS
  ingress {
    description = "Allow AWS Management Console access" 
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

#Security Group for EKS Worker Nodes (Kubernetes Nodes)
# Este SG permite el tráfico necesario para que los nodos de Kubernetes funcionen correctamente.
#Aquí restringimos el tráfico a los puertos que realmente necesitarán los nodos de EKS (por ejemplo, solo el tráfico interno entre nodos y desde ALB).
# Este SG permite que los nodos de Kubernetes puedan recibir tráfico interno entre ellos y solo desde el ALB.
resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow internal communication between EKS nodes"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }

  ingress {
    description = "Allow traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Allow traffic from ALB (HTTPS)"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-sg"
  }
}


# --- Security Group for RDS (Database) ---
# Este SG permite que solo ciertas instancias accedan a la base de datos (en este caso, solo EKS nodes o Load Balancer si hiciera falta).
#Para RDS, este SG permite el tráfico solo desde los nodos de EKS, o desde cualquier otra instancia que necesite conectarse a la base de datos (por ejemplo, si el ALB o una instancia EC2 lo requiere).

# --- Security Group for RDS (Database) ---
# Este SG permite que solo los nodos de EKS puedan conectarse al puerto de la base de datos.
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow access to PostgreSQL (5432) from EKS nodes"
    from_port       = 5432 # Puerto típico para PostgreSQL
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
  }

  ingress {
    description = "Allow access to PostgreSQL from ALB (if needed)"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Esto sería en caso de que necesites que el ALB también acceda a la base de datos
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# Resumen de las restricciones de seguridad:
# ALB: solo permite tráfico desde Internet en los puertos 80 (HTTP) y 443 (HTTPS). Esto asegura que el tráfico solo provenga de clientes externos.
# EKS Worker Nodes: permiten tráfico interno entre ellos y tráfico limitado desde ALB. Esto evita accesos innecesarios desde fuera del entorno de Kubernetes.
# RDS: permite solo que los nodos de EKS puedan conectarse a la base de datos en el puerto 5432 (para PostgreSQL). No permite acceso directo desde Internet.

