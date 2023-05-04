resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = var.eks_master_role_arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids = var.subnet_ids
    # [
    #   var.subnet_1a,
    #   var.subnet_1b,
    #   var.subnet_1c
    # ]
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids = var.eks_cluster_sg
  }

  

  # depends_on = [
  #   aws_iam_role_policy_attachment.eks_cluster_cluster,
  #   aws_iam_role_policy_attachment.eks_cluster_service
  # ]

  tags = var.tags
}

resource "aws_eks_addon" "eks_cluster_addon_cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"
}