####Locals
locals {
  eks-node-private-userdata = <<USERDATA
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash -xe
sudo /etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_cluster_endpoint}' --b64-cluster-ca '${var.certificate_authority_data}' '${var.cluster-name}'
echo "Running custom user data script" > /tmp/me.txt
yum install -y amazon-ssm-agent
echo "yum'd agent" >> /tmp/me.txt
systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
date >> /tmp/me.txt

--==MYBOUNDARY==--
USERDATA
}

variable "eks_cluster_version" {}
variable "key_name" {}
variable "allnodegroup_sg_id" {}
variable "cluster-name" {}
variable "subnet_ids" {}
variable "nodegroup_role_arn" {}
variable  "eks_cluster_endpoint"{}
variable "certificate_authority_data" {
  
}