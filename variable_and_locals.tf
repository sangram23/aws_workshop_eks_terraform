variable "public_subnet" {
    type = map
  
}
variable "private_subnet" {
    type = map
  
}

variable "vpc_cidr" {
    description = "all CIDR"
    type = map
  
}

variable "public_cidr_tags" {
    description = "all CIDR"
    type = map
  
}

variable "subnet_public_access_tags" {
    type = map
}
variable "cluster-name" {
    type = string
    default = "eks_airflow"
  
}
variable "region" {
    type = string
    default = "us-east-1"
  
}
variable "kubernetes_version" {
    type = string
    default = "1.21"
  
}

