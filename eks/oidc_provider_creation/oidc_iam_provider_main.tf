resource "aws_iam_openid_connect_provider" "eks_iam_oidc_provider" {

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list =[ var.eks_tls_certificates ]#[data.tls_certificate.eks_cluste.certificates[0].sha1_fingerprint]
  #url             = aws_eks_cluster.example.identity[0].oidc[0].issuer
  url              = var.eks_cluster_oidc_issuer
}
# data "tls_certificate" "eks_cluster" {
#   #url = aws_eks_cluster.example.identity[0].oidc[0].issuer
#   url = var.eks_cluster_oidc_issuer
# }