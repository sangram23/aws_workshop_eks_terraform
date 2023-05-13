output "eks_iam_oidc_provide_arn" {
    value = aws_iam_openid_connect_provider.eks_iam_oidc_provider.arn
  
}