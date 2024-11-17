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

resource "aws_instance" "instance" {
  ami = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "varible-instance"
  }
}

