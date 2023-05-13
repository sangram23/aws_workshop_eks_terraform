output "eks_cluster_name" {
  value=aws_eks_cluster.eks_cluster.name
}

# output cluster-sg {
#   value=aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
# }

# output ca {
#   value=aws_eks_cluster.cluster.certificate_authority[0].data
# }

output "eks_cluster_endpoint" {
  value=aws_eks_cluster.eks_cluster.endpoint
}
output "eks_cluster_certificate_authority_data" {
  value=aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
output "eks_cluster_oidc_provider_issuer" {
  value=aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
