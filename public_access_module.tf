module "public_access_vpc" {
    source = "./public_access/vpc/"
    vpc_public_cidr=var.vpc_cidr["public_cidr"]
    tags=var.public_cidr_tags
  
}

module "igw" {
    source = "./public_access/igw/"
    vpc_id=module.public_access_vpc.vpc_public_access_id
    depends_on = [ module.public_access_vpc ]
  
}

module "public_access_subnet" {
    source = "./public_access/subnet/"
    subnet_public_access_tags=var.subnet_public_access_tags
    for_each=var.public_subnet
    subnet_cidr=each.value.az_cidr
    availability_zone=each.value.az_value
    vpc_id = module.public_access_vpc.vpc_public_access_id
    gateway_id=module.igw.internet_gateway_id
  
}
# module "key_pair" {
#     source = "./public_access/key_pair/"
  
# }
module "bastion_host" {
    source = "./public_access/bastion_host/"
    vpc_id=module.public_access_vpc.vpc_public_access_id
    subnet_id=module.public_access_subnet["az_1a"].public_subnet_id
    key_name="mytest"

  
}