resource "aws_instance" "instance" {
  ami = var.ami
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.nano")

}
