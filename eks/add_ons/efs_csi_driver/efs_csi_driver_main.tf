# Security group and rules for the EFS.
resource "aws_security_group" "efs_sg" {
  name        = "${var.cluster_name}-efs-sg"
  description = "EFS Security Group for ${var.cluster_name}."
  vpc_id      = var.vpc_id
 # tags        = merge(module.cluster_tags.tags, local.tags, var.extra_tags)

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group_rule" "ingress" {
  description       = "Allow inbound traffic from the EKS CIDR block"
  type              = "ingress"
  from_port         = 2049 # NFS
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_id]
  security_group_id = aws_security_group.efs_sg.id
}
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_sg.id
}
# The EFS itself.
resource "aws_efs_file_system" "efs_fs" {
  encrypted                       = var.encrypted
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  #tags                            = merge(module.cluster_tags.tags, local.tags, var.extra_tags)
  throughput_mode                 = var.throughput_mode
}
# The EFS mount targets.
resource "aws_efs_mount_target" "this" {
  count           = length(var.eks_subnet_ids)
  file_system_id  = aws_efs_file_system.efs_fs.id
  subnet_id       = var.subnet_ids
  security_groups = [aws_security_group.efs_sg.id]
}

# The EFS policy
resource "aws_efs_file_system_policy" "efs_policy" {
  file_system_id = aws_efs_file_system.efs_fs.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "elasticfilesystem:ClientWrite",
            "elasticfilesystem:ClientRootAccess",
            "elasticfilesystem:ClientMount",
          ]
          Condition = {
            Bool = {
              "elasticfilesystem:AccessedViaMountTarget" : "true"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = aws_efs_file_system.efs.arn
          Sid      = "efsClientAccess"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

# IAM role for the EFS CSI Controller
resource "aws_iam_role" "efs_csi_controller_iam_role" {
  name = format("%s%s-%s",var.role_prefix, "efs-csi-controller", var.cluster_name)
  #permissions_boundary = var.permissions_boundary_arn
  description = "IAM role for the EFS CSI controller for the ${var.cluster_name} cluster."
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${local.oidc_provider_short}:sub" = "system:serviceaccount:${var.namespace}:${var.serviceaccount_name}"
            }
          }
          Effect = "Allow"
          Principal = {
            Federated = var.iam_oidc_connect_provider_arn
          }
          Sid = "efcCsiControllerAccount"
        },
      ]
      Version = "2012-10-17"
    }
  )
  #tags = merge(module.cluster_tags.tags, local.tags, var.extra_tags)
}
resource "aws_iam_role_policy" "efs_csi_controller_iam_policy" {
  name = format("%s%s-%s",var.role_prefix, "efs-csi-controller", var.cluster_name)
  role = aws_iam_role.efs_csi_controller_iam_role.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "elasticfilesystem:DescribeFileSystems",
            "elasticfilesystem:DescribeAccessPoints",
            "elasticfilesystem:DeleteAccessPoint",
            "elasticfilesystem:CreateAccessPoint"
          ]
          Effect = "Allow"
          Resource = [ 
            aws_efs_file_system.efs_fs.arn,
            "arn:aws:elasticfilesystem:${var.aws_region}:${var.aws_account_id}:access-point/*"
          ]
          Sid = "efsCsiControllerOwn"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "helm_release" "efs_csi_driver" {
  chart            = "${path.module}/helm/efs-csi-driver"
  create_namespace = true
  name             = "efs-csi-driver-${random_pet.release_suffix.id}"
  namespace        = var.namespace
  recreate_pods    = false
  timeout          = var.helm_release_timeout
  values           = [templatefile("${path.module}/template/values.yaml.tpl", local.helm_values)]
}