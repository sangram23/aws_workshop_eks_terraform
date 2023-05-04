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