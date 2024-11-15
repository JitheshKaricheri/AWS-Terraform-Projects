resource "aws_s3_bucket" "bb-bucket" {
  bucket = "my-bb-test-bucket"

  tags = {
    Name        = "My-bbbucket"
    Environment = "Dev"
  }
}