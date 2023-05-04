

resource "aws_security_group" "sg_vpc_endpoint" {
  name   = "Allow port 443 from VPC CIDR"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  tags = {
    "Name"   ="enpoints"
    "Label"  = "TF-EKS All Nodes Comms"
  }
}

#############All Nodes Secuirty Group ##############
resource "aws_security_group" "allnodes-sg" {
  description = "Communication between all nodes in the cluster"
  vpc_id      = var.vpc_id
  tags = {
    "Name"   = format("eks-%s-cluster/ClusterSharedNodeSecurityGroup",var.cluster-name)
    "Label"  = "TF-EKS All Nodes Comms"
  }
}


#############Cluster Secuirty Group ##############

resource "aws_security_group" "eks_cluster_sg" {
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = format("eks-%s-cluster/ControlPlaneSecurityGroup",var.cluster-name)
    "Label" = "TF-EKS Control Plane & all worker nodes comms"
  }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

}

resource "aws_security_group_rule" "eks_cluster_sg_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_cluster_sg.id
}
resource "aws_security_group_rule" "eks_cluster_sg_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
  security_group_id = aws_security_group.eks_cluster_sg.id
}

