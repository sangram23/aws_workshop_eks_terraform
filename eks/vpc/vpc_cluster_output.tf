output "vpc_eks_id" {
  value = aws_vpc.vpc_eks_cluster.id
}
output "vpc_eks_cluster_arn" {
    value = aws_vpc.vpc_eks_cluster.arn
  
}

output "vpc_eks_cluster_cidr" {
  value = aws_vpc.vpc_eks_cluster.cidr_block
}
