resource "aws_vpc_peering_connection" "public_private" {
  
peer_vpc_id = var.vpc_peer_id
vpc_id = var.accepter_id
auto_accept = true

accepter {
allow_remote_vpc_dns_resolution = true
}

requester {
allow_remote_vpc_dns_resolution = true
}

tags = {
Name = "vpc-east to vpc-eastt VPC peering"
}
}

