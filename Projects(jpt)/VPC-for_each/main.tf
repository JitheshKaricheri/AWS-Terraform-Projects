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

variable "vpcs" {
    default = [
        "10.0.0.0/16",
        "20.0.0.0/16"
    ]
  

}

resource "aws_vpc" "vpc" {
    for_each = toset(var.vpcs)
    cidr_block = each.value
  
}
