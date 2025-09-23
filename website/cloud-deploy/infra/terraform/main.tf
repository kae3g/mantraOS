locals {
  tags = {
    Project = var.project
    Stack   = "website"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project}-vpc"
  cidr = "10.42.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.42.1.0/24", "10.42.2.0/24", "10.42.3.0/24"]
  public_subnets  = ["10.42.11.0/24", "10.42.12.0/24", "10.42.13.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      min_size       = var.min_size
      desired_size   = var.desired_size
      max_size       = var.max_size
    }
  }

  cluster_addons = {
    coredns   = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni   = { most_recent = true }
  }

  enable_irsa = true
  tags        = local.tags
}

resource "aws_ecr_repository" "site" {
  name                 = "${var.project}/site"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = local.tags
}