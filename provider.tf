terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

provider "helm" {
  debug = true
  kubernetes {
    host=module.eks_cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "aws"
      args = [ 
        "--region",
        "us-east-1",
        "eks",
        "get-token",
        "--cluster-name",
        var.cluster-name
       ]
    }
  }
  
}

