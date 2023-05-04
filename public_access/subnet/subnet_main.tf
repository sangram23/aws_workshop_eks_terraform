# Creating 1st web subnet 
resource "aws_subnet" "public_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block             = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone
tags = var.subnet_public_access_tags
}

###Routetable 

# Creating Route Table
resource "aws_route_table" "public_subne_route_table" {
    vpc_id = var.vpc_id
route {
        cidr_block = "0.0.0.0/0"
        gateway_id = var.gateway_id
    }
tags = {
        Name = "Route to internet"
    }
}
# Associating Route Table
resource "aws_route_table_association" "public_subne_route_table_associate" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id =  aws_route_table.public_subne_route_table.id
}