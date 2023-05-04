variable eks_master_role_arn{}
variable "kubernetes_version" {
#   type    = string
#   default = "1.21"
}
variable eks_cluster_sg{}
#variable "iam_role_policy" {}



variable "cluster_name" {
#   type = string
}

# variable "subnet_1a" {
#   type = string
# }

# variable "subnet_1b" {
#   type = string
# }
variable "subnet_ids" {
  
}
# variable "cidr_block" {
# #   type = string
# }

variable "tags" {
#   type = map(string)
}