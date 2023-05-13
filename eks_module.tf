module "eks_private_vpc" {
    source = "./eks/vpc/"
    vpc_cidr = var.vpc_cidr["private_eks_cidr"]
    
}
module "eks_private_subnets" {
    source = "./eks/subnet/"
    vpc_id = module.eks_private_vpc.vpc_eks_id
    cluster-name = var.cluster-name
    for_each = var.private_subnet
    availability_zone=each.value.az_value
    subnet_cidr=each.value.az_cidr  
} 
module "eks_security_group" {
    source = "./eks/security_group/"
    vpc_id = module.eks_private_vpc.vpc_eks_id
    cluster-name = var.cluster-name
    cidr_block = var.vpc_cidr["private_eks_cidr"]
        
} 
module "eks_vpc_endpoints" {
    source = "./eks/vpc_endpoint/"
    vpc_id = module.eks_private_vpc.vpc_eks_id
    security_group_ids=[module.eks_security_group.cluster_sg_id,module.eks_security_group.allnodes_sg_id,module.eks_security_group.sg_vpc_endpoint_id]
    region = var.region
    subnet_ids=[module.eks_private_subnets["az_1a"].sub-priv1-id,module.eks_private_subnets["az_1b"].sub-priv1-id,module.eks_private_subnets["az_1c"].sub-priv1-id]
    route_table_ids=[module.eks_private_subnets["az_1a"].rtb-priv1-id,module.eks_private_subnets["az_1b"].rtb-priv1-id,module.eks_private_subnets["az_1c"].rtb-priv1-id]

    
} 
module "eks_iam" {
    source = "./eks/IAM/"
    tags=var.public_cidr_tags
    cluster_name = var.cluster-name
    
} 
module "eks_cluster" {
    source = "./eks/cluster/"
    cluster_name = var.cluster-name
    kubernetes_version = var.kubernetes_version
    tags=var.public_cidr_tags
    eks_master_role_arn=module.eks_iam.eks_master_role_arn
    eks_cluster_sg=[module.eks_security_group.cluster_sg_id]
    depends_on = [module.eks_iam]
    #iam_role_policy = [module.eks_iam.aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,module.eks_iam.aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy]
    subnet_ids=[module.eks_private_subnets["az_1a"].sub-priv1-id,module.eks_private_subnets["az_1b"].sub-priv1-id,module.eks_private_subnets["az_1c"].sub-priv1-id]
    
} 

data "tls_certificate" "eks_tls_certificates" {
  #url = aws_eks_cluster.example.identity[0].oidc[0].issuer
  #url = var.eks_cluster_oidc_issuer
  url = module.eks_cluster.eks_cluster_oidc_provider_issuer
  depends_on = [ module.eks_cluster ]
}
module "eks_node_ng_airflow" {
    source = "./eks/nodegroup/airflow/"
    cluster-name = var.cluster-name
    eks_cluster_version = var.kubernetes_version
    key_name="mytest"
    nodegroup_role_arn=module.eks_iam.nodegroup_role_arn
    eks_cluster_endpoint=module.eks_cluster.eks_cluster_endpoint
    certificate_authority_data=module.eks_cluster.eks_cluster_certificate_authority_data
    allnodegroup_sg_id=[module.eks_security_group.allnodes_sg_id,module.eks_security_group.cluster_sg_id]
    subnet_ids=[module.eks_private_subnets["az_1a"].sub-priv1-id,module.eks_private_subnets["az_1b"].sub-priv1-id,module.eks_private_subnets["az_1c"].sub-priv1-id]
    
} 
module "eks_oidc" {
    source = "./eks/oidc_provider_creation/"
    eks_cluster_oidc_issuer = module.eks_cluster.eks_cluster_oidc_provider_issuer
    eks_tls_certificates = data.tls_certificate.eks_tls_certificates.certificates[0].sha1_fingerprint
    depends_on = [ module.bastion_host,data.tls_certificate.eks_tls_certificates ]
  
}
module "addon_efs_csi_driver" {
    source = "./eks/add_ons/efs_csi_driver/"
   cluster_name=var.cluster-name
   vpc_id=module.eks_private_vpc.vpc_eks_id
   vpc_block=var.vpc_cidr["private_eks_cidr"]
   encrypted= true
   performance_mode = "generalPurpose"
   #provisioned_throughput_in_mibps=
   throughput_mode="elastic"
   subnet_id_az_1a=module.eks_private_subnets["az_1a"].sub-priv1-id
   subnet_id_az_1b=module.eks_private_subnets["az_1b"].sub-priv1-id
   subnet_id_az_1c=module.eks_private_subnets["az_1c"].sub-priv1-id
   serviceaccount_name="efs-csi-controller-sa"
   oidc_provider=replace(module.eks_cluster.eks_cluster_oidc_provider_issuer, "https://", "")
   aws_region="us-east-1"
   aws_account_id="107457029648"
   iam_oidc_connect_provider_arn=module.eks_oidc.eks_iam_oidc_provide_arn
   depends_on = [  module.bastion_host,data.tls_certificate.eks_tls_certificates,module.eks_private_subnets ]
  
}