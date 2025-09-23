terraform {
  required_version = ">= 1.5.0"
  # For remote state, configure backend via backend.hcl and terraform init -backend-config=backend.hcl
  # backend "s3" {}
}

provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}
