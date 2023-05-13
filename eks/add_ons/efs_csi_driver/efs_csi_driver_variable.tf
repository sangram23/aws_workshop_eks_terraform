variable "cluster_name" {}
variable "vpc_block" {}
variable "vpc_id" {}
variable "encrypted" {}
variable "performance_mode" { }
#variable "provisioned_throughput_in_mibps" {}
variable "throughput_mode" {}
variable "subnet_id_az_1a" {}
variable "subnet_id_az_1b" {}
variable "subnet_id_az_1c" {}
variable "oidc_provider" {}
variable "aws_region" {}
variable "serviceaccount_name" {}
variable "aws_account_id" {}
variable "iam_oidc_connect_provider_arn" {}
# variable "namespace" {}