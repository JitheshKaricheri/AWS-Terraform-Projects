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

variable "ami" {
  default = "ami-066784287e358dad1"
}

variable "instance_type" {
   type = map(string)
   default = {
     "dev" = "t2.micro"
     "stage"= "t2.medium"
     "prod" = "t2.xlarge"
   }
}

resource "aws_instance" "instance" {
    ami = var.ami
    instance_type = lookup(var.instance_type, terraform.workspace, "t2.nano")

 tags = {

    Name = "aws-instance" 
 } 

}
