# A Launch template

resource "aws_launch_template" "lt-ng1" {
  #depends_on = [null_resource.auth_cluster]
  instance_type           = "t3.small"
  key_name                = var.key_name
  name                    = format("at-lt-%s-ng1", var.cluster-name)
  tags                    = {}
  image_id                = data.aws_ssm_parameter.eksami.value
  user_data            = base64encode(local.eks-node-private-userdata)
  vpc_security_group_ids  = var.allnodegroup_sg_id
  tag_specifications { 
        resource_type = "instance"
    tags = {
        Name = format("%s-ng1", var.cluster-name)
        }
    }
  lifecycle {
    create_before_destroy=true
  }
}


# A NodeGroup using the launch template above

resource "aws_eks_node_group" "ng1" {
  #ami_type       = "AL2_x86_64"
  depends_on     = [aws_launch_template.lt-ng1]
  cluster_name   = var.cluster-name
  disk_size      = 0
  instance_types = []
  labels = {
    "alpha.eksctl.io/cluster-name"   = var.cluster-name
    "alpha.eksctl.io/nodegroup-name" = format("ng1-%s", var.cluster-name)
  }
  node_group_name = format("ng1-%s", var.cluster-name)
  node_role_arn   = var.nodegroup_role_arn  #data.terraform_remote_state.iam.outputs.nodegroup_role_arn
  #release_version = "1.17.11-20201007"
  subnet_ids = var.subnet_ids
#    [
#       data.terraform_remote_state.net.outputs.sub-priv1,
#       data.terraform_remote_state.net.outputs.sub-priv2,
#       data.terraform_remote_state.net.outputs.sub-priv3,
#   ]
  tags = {
    "alpha.eksctl.io/cluster-name"                = var.cluster-name
    "alpha.eksctl.io/eksctl-version"              = "0.29.2"
    "alpha.eksctl.io/nodegroup-name"              = format("ng1-%s", var.cluster-name)
    "alpha.eksctl.io/nodegroup-type"              = "managed"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = var.cluster-name
  }
  #version = "1.17"

  launch_template {
    name    = aws_launch_template.lt-ng1.name
    version = "1"
  }

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  timeouts {}
}


# A null resource (this will auth us to the cluster)

# resource "null_resource" "auth_cluster" {
# triggers = {
#     always_run = "${timestamp()}"
# }
# # depends_on = [data.aws_eks_cluster.eks_cluster]
# provisioner "local-exec" {
#     on_failure  = fail
#     interpreter = ["/bin/bash", "-c"]
#     command     = <<EOT
#         echo -e "\x1B[31m Warning! Checking Authorization ${var.cluster-name}...should see Server Version: v1.17.xxx \x1B[0m"
#         ./auth.sh
#         echo "************************************************************************************"
#      EOT
# }
# }



