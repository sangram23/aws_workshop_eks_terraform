output "nodegroup_role_arn" {
  value = aws_iam_role.eks-nodegroup-ng-ma-NodeInstanceRole-1GFKA1037E1XO.arn
}
output "eks_master_role_arn" {
  value = aws_iam_role.eks_master_role.arn
}