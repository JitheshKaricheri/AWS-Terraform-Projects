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

resource "aws_s3_bucket" "my-bucket" {
  bucket = "jik-bucket"
}

resource "aws_s3_bucket_versioning" "version" {
  bucket = aws_s3_bucket.my-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "KMS" {
  description             = "key"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "SSE" {
  bucket = aws_s3_bucket.my-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.KMS.id
      sse_algorithm     = "aws:kms"
    }
  }

}
