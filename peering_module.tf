module "peering" {
  source = "./vpc_peering"
  vpc_peer_id=module.public_access_vpc.vpc_public_access_id
  accepter_id=module.eks_private_vpc.vpc_eks_id
  depends_on = [ module.eks_cluster,module.eks_private_vpc,module.public_access_vpc,module.eks_private_subnets ,module.public_access_subnet]


}


resource "aws_route" "vpc-peering-route-public" {
route_table_id =  module.public_access_subnet["az_1a"].public_subne_route_table_id
destination_cidr_block =   var.vpc_cidr["private_eks_cidr"] ###"${module.vpc-east.public_subnets_cidr_blocks[count.index]}"
vpc_peering_connection_id = module.peering.public_private_peering_id
depends_on = [ module.peering ]
}
resource "aws_route" "vpc-peering-route-eks" {
for_each =   var.private_subnet
route_table_id = module.eks_private_subnets[each.key].rtb-priv1-id
destination_cidr_block =   var.vpc_cidr["public_cidr"] ###"${module.vpc-east.public_subnets_cidr_blocks[count.index]}"
vpc_peering_connection_id = module.peering.public_private_peering_id
depends_on = [ module.peering ]
}