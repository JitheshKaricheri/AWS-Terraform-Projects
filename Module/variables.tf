variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type = string
}

variable "subnet_cidr" {
    description = "subnets CIDRs"
    type = list(string)
}

variable "subnet_names" {
  description = "Subnet_names"
  type = list(string)
  default = [ "publicSubnet1", "publicSubnet2"]
}
