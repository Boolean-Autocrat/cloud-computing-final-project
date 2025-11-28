
provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source = "./vpc"

  project_name = var.project_name
  aws_region   = var.aws_region
}

module "eks" {
  source = "./eks"

  project_name = var.project_name
  aws_region   = var.aws_region
  vpc_id       = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
}

module "rds" {
  source = "./rds"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  db_username       = var.db_username
  db_password       = var.db_password
}

module "dynamodb" {
  source = "./dynamodb"

  project_name = var.project_name
  aws_region   = var.aws_region
}

module "s3" {
  source = "./s3"

  project_name = var.project_name
  aws_region   = var.aws_region
}
