terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.62.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type

}