output "eks_endpoint" {
  description = "EKS cluster endpoint from module"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_names" {
  description = "List of all EKS cluster names"
  value       = module.eks.aws_eks_cluster_names
}

output "vpc_id" {
  value       = module.eks.vpc_id
  description = "The ID of the VPC"
}

output "public_subnets" {
  value       = module.eks.public_subnets
  description = "List of public subnet IDs"
}

output "private_subnets" {
  value       = module.eks.private_subnets
  description = "List of private subnet IDs"
}

output "vpc_cidr_block" {
  value       = module.eks.vpc_cidr_block
  description = "The CIDR block of the VPC"
}