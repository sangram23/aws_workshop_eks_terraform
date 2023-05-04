# Creating VPC
resource "aws_vpc" "vpc_public_access" {
  cidr_block       = "${var.vpc_public_cidr}"
  instance_tenancy = "default"
  enable_dns_hostnames = true
tags = var.tags
}