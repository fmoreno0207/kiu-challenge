# IAM Role for EKS Cluster
# Este recurso crea un rol IAM para el clúster de EKS. Este rol permite a EKS interactuar con otros servicios de AWS en nombre del clúster.
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com" # EKS necesita este permiso para asumir este rol
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# Attach policies to EKS Cluster Role
# Este recurso adjunta la política AmazonEKSClusterPolicy al rol del clúster de EKS. Esta política proporciona los permisos necesarios
# para que el clúster de EKS funcione correctamente.
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" # Política que permite gestionar recursos de EKS
  role       = aws_iam_role.eks_role.name
}

# IAM Role for EKS Worker Nodes
# Este recurso crea un rol IAM para los nodos de trabajo de EKS. Este rol permite a los nodos interactuar con los servicios de AWS
# necesarios para ejecutar contenedores y gestionar tareas dentro del clúster.
resource "aws_iam_role" "eks_worker_role" {
  name = "eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com" # Los nodos EC2 deben poder asumir este rol para interactuar con AWS
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# Attach policies to EKS Worker Node Role
# Este recurso adjunta la política AmazonEKSWorkerNodePolicy al rol de los nodos de trabajo. Esto permite a los nodos de trabajo
# interactuar con otros servicios de AWS como EC2, EBS y CloudWatch, entre otros.
resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" # Política que permite la gestión de nodos y tareas dentro de EKS
  role       = aws_iam_role.eks_worker_role.name
}

# Attach AmazonEC2ContainerRegistryReadOnly policy for accessing ECR
# Este recurso adjunta la política AmazonEC2ContainerRegistryReadOnly al rol de los nodos de trabajo de EKS. Esto permite a los
# nodos de EKS acceder de manera de solo lectura a Amazon ECR (Elastic Container Registry) para obtener imágenes de contenedores.
resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # Permite a los nodos acceder a las imágenes de ECR
  role       = aws_iam_role.eks_worker_role.name
}
