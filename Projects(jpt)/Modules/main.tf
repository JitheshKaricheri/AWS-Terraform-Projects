terraform {
  required_providers {
    aws= {
        source = "hashicorp/aws"
        version = "5.58.0"

    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "inst_module" {
  source = "./module/ec2"
}

module "vpc_module" {
  source = "./module/vpc"
}