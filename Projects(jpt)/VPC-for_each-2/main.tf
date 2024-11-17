terraform {
  required_providers {
    aws = {

        source = "hashicorp/aws"
        version = "5.58.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "vpc" {
    default = {
        vpc-1 = "10.0.0.0/16",
        vpc-2 = "20.0.0.0/16"

    }
  
}

resource "aws_vpc" "test" {
  for_each = var.vpc
  cidr_block = each.value
  tags = {
    Name = each.key
  }
}