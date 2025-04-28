output "eks_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_role.arn
}

output "worker_role_arn" {
  description = "ARN of the EKS worker IAM role"
  value       = aws_iam_role.eks_worker_role.arn
}
output "eks_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = aws_iam_role.eks_role.name
}
output "worker_role_name" {
  description = "Name of the EKS worker IAM role"
  value       = aws_iam_role.eks_worker_role.name
}