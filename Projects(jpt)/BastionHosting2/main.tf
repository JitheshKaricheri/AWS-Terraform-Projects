resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/25"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
}

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.128/25"
  availability_zone = "us-east-1a"
  map_customer_owned_ip_on_launch = "false"
}

resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.vpc.id
    
  }

  resource "aws_route_table" "private-rt" {
    vpc_id = aws_vpc.vpc.owner_id

  }

resource "aws_route_table_association" "public-rt-association" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-rt-association" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

}

resource "aws_route" "pub-rt-pub" {
  route_table_id = aws_route_table.public-rt.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  name = "sg-bh"

ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

}

}

resource "aws_instance" "public-instance" {
  ami = 
instance_type =
key_name = "ubu"
 subnet_id = aws_subnet.public-subnet.id
 security_groups = [aws_security_group.sg.id]
 user_data = file()

}

resource "aws_instance" "private-instance" {
  ami = 
  instance_type =
  key_name = "ubu"
  subnet_id = aws_subnet.private-subnet.id
  security_groups = [aws_security_group.sg.id]

}
