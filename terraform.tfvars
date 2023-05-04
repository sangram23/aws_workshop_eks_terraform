vpc_cidr = {
    public_cidr = "10.0.0.0/16"
    private_eks_cidr= "172.2.0.0/16"
}
public_cidr_tags={
    name="VPC_PUBLIC"
    type="Internet access"
}

subnet_public_access_tags={
    name="public_access"
}
public_subnet = {
    az_1a = {az_cidr="10.0.1.0/24", az_value="us-east-1a"}
   az_1b = {az_cidr="10.0.2.0/24", az_value="us-east-1b"},
    az_1c = {az_cidr="10.0.3.0/24", az_value="us-east-1c"},
}
private_subnet= {
    az_1a = {az_cidr="172.2.1.0/24", az_value="us-east-1a"}
    az_1b = {az_cidr="172.2.2.0/24", az_value="us-east-1b"},
    az_1c = {az_cidr="172.2.3.0/24", az_value="us-east-1c"},
}
   


