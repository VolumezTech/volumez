provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${var.cluster_owner}-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name                 = "${var.cluster_owner}-vpc-${random_string.suffix.result}"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "Origin" = "Volumez"
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = local.cluster_name
  cluster_version                 = "1.21"
  subnet_ids                      = module.vpc.private_subnets
  vpc_id                          = module.vpc.vpc_id
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_volumez = {
      description = "Node to node - Port 8009 required by Volumez"
      protocol    = "tcp"
      from_port   = 8009
      to_port     = 8009
      type        = "ingress"
      cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
    }
    egress_volumez = {
      description = "Node to node - Port 8009 required by Volumez"
      protocol    = "tcp"
      from_port   = 8009
      to_port     = 8009
      type        = "egress"
      cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
    }
    ingress__volumez2 = {
      description = "Node to node - Port 3260 required by Volumez"
      protocol    = "tcp"
      from_port   = 3260
      to_port     = 3260
      type        = "ingress"
      cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
    }

    egress__volumez2 = {
      description = "Node to node - Port 3260 required by Volumez"
      protocol    = "tcp"
      from_port   = 3260
      to_port     = 3260
      type        = "egress"
      cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
    }
  }

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  eks_managed_node_groups = {
    volumez-media-ng = {
      name = "volumez-media-eks"

      enable_bootstrap_user_data = true

      pre_bootstrap_user_data = <<-EOT
      MIME-Version: 1.0
      Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

      --==MYBOUNDARY==
      Content-Type: text/x-shellscript; charset="us-ascii"

      #!/bin/bash
      uuid=$(uuidgen)
      sudo hostnamectl set-hostname $uuid

      --==MYBOUNDARY==--\\
      EOT
      
      desired_size = var.media_node_count
      min_size     = var.media_node_count
      max_size     = var.media_node_count

      instance_types = ["${var.media_node_type}"]
      capacity_type  = "ON_DEMAND"
      labels = {
        Origin        = "Volumez"
        GithubRepo    = "terraform-aws-eks"
        instance-type = "media-ng"
      }
    }
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}
