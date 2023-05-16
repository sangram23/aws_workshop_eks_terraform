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
  cidr_blocks       = [var.vpc_block]
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
  #tags                            = merge(module.cluster_tags.tags, local.tags, var.extra_tags)
  throughput_mode                 = var.throughput_mode
}
# The EFS mount targets.
resource "aws_efs_mount_target" "efs_fs_mount_target_1a" {

  file_system_id  = aws_efs_file_system.efs_fs.id
  subnet_id       = var.subnet_id_az_1a
  security_groups = [aws_security_group.efs_sg.id]
}
resource "aws_efs_mount_target" "efs_fs_mount_target_1b" {

  file_system_id  = aws_efs_file_system.efs_fs.id
  subnet_id       = var.subnet_id_az_1b
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "efs_fs_mount_target_1c" {

  file_system_id  = aws_efs_file_system.efs_fs.id
  subnet_id       = var.subnet_id_az_1c
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
          Resource = aws_efs_file_system.efs_fs.arn
          Sid      = "efsClientAccess"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

# IAM role for the EFS CSI Controller
resource "aws_iam_role" "efs_csi_controller_iam_role" {
  name = format("%s-%s","efs-csi-controller", var.cluster_name)
  #permissions_boundary = var.permissions_boundary_arn
  description = "IAM role for the EFS CSI controller for the ${var.cluster_name} cluster."
  assume_role_policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "efcCsiControllerAccount",
            "Effect": "Allow",
            "Principal": {
                "Federated": var.iam_oidc_connect_provider_arn
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${var.oidc_provider}:sub": "system:serviceaccount:default:${var.serviceaccount_name}"
                }
            }
        }
    ]
}
  )
  #tags = merge(module.cluster_tags.tags, local.tags, var.extra_tags)
}
resource "aws_iam_role_policy" "efs_csi_controller_iam_policy" {
  name = format("%s-%s", "efs-csi-controller", var.cluster_name)
  role = aws_iam_role.efs_csi_controller_iam_role.id
  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:DeleteAccessPoint",
                "elasticfilesystem:CreateAccessPoint",
                "elasticfilesystem:DescribeMountTargets",
                "ec2:DescribeAvailabilityZones",
                "elasticfilesystem:TagResource"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:elasticfilesystem:us-east-1:107457029648:file-system/fs-0df77c25e3d12eea6",
                "arn:aws:elasticfilesystem:us-east-1:107457029648:access-point/*"
            ],
            "Sid": "efsCsiControllerOwn"
        }
    ]
}
  )
}

# resource "helm_release" "efs_csi_driver" {
#   chart            = "${path.module}/helm/efs-csi-driver"
#   create_namespace = true
#   name             = "efs-csi-driver-${random_pet.release_suffix.id}"
#   namespace        = var.namespace
#   recreate_pods    = false
#   timeout          = var.helm_release_timeout
#   values           = [templatefile("${path.module}/template/values.yaml.tpl", local.helm_values)]
# }


resource "helm_release" "efs_csi_driver" {
  depends_on = [aws_iam_role.efs_csi_controller_iam_role]            
  name       = "aws-efs-csi-driver"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"

  namespace = "kube-system"     

  set {
    name = "image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/aws-efs-csi-driver" # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  }       

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value =    var.serviceaccount_name #"efs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.efs_csi_controller_iam_role.arn}"
  }
    
}
