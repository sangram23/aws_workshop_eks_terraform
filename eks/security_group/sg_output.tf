output "allnodes_sg_id" {
  value = aws_security_group.allnodes-sg.id
}
output "cluster_sg_id" {
  value = aws_security_group.eks_cluster_sg.id
}
output "sg_vpc_endpoint_id" {
  value = aws_security_group.sg_vpc_endpoint.id
}

