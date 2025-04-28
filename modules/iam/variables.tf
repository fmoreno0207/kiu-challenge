variable "eks_role_name" {
  description = "Name of the EKS cluster IAM role"
  type        = string
  default     = "eks-cluster-role"
}

variable "worker_role_name" {
  description = "Name of the EKS worker IAM role"
  type        = string
  default     = "eks-worker-role"
}
