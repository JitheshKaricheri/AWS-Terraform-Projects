terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0b72821e2f351e396"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
depends_on = [ aws_s3_bucket.bucket ]
  
}



resource "aws_s3_bucket" "bucket" {
  bucket = "bucketproject00"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}