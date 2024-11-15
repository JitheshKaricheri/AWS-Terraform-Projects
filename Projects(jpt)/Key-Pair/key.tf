terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "key1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "pub-key" {
  key_name   = "terr-key"
  public_key = tls_private_key.key1.public_key_openssh
}
resource "local_file" "localkey" {
  content  = tls_private_key.key1.private_key_pem
  filename = "terr-key"

}
  