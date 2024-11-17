variable "ami" {
  default = "ami-066784287e358dad1"
}

variable "instance_type" {
    type = map(string)
  default = {
  "dev" = "t2.micro"
  "stage" = "t2.medium"
  "prod" = "t2.small" 
  
  }
}