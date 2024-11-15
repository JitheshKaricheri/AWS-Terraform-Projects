# creating vpc

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test-vpc"
  }

}

# creating subnet-1

resource "aws_subnet" "pub-sub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "test-sub-pub"
  }
}

# creating subnet-2

resource "aws_subnet" "prv-sub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "test-sub-prv"
  }
}

# creating internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

# creating public route table

resource "aws_route_table" "rt-pub" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# pub-sub-association

resource "aws_route_table_association" "pub-sub-as" {
  subnet_id      = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.rt-pub.id
}

# creating private route table

resource "aws_route_table" "rt-prv" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# prv-sub-association

resource "aws_route_table_association" "prv-sub-as" {
  subnet_id      = aws_subnet.prv-sub.id
  route_table_id = aws_route_table.rt-prv.id
}

# add a route to the pub-route table

resource "aws_route_table" "pub-internet-access" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# creating ec2-instance

resource "aws_instance" "web" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}