

output "aws_eks_cluster_names" {
  description = "List of all EKS cluster names"
  value       = [for cluster in aws_eks_cluster.eks : cluster.name]
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = aws_eks_cluster.eks[0].endpoint
}
output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "public_subnets" {
  value       = aws_subnet.public-subnet[*].id
  description = "List of public subnet IDs"
}

output "private_subnets" {
  value       = aws_subnet.private-subnet[*].id
  description = "List of private subnet IDs"
}

output "vpc_cidr_block" {
  value       = aws_vpc.vpc.cidr_block
  description = "The CIDR block of the VPC"
}