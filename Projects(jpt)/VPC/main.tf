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

resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "us-east-1a"

  tags = {

    Name = "sub-1"

  }

}

resource "aws_route_table" "rt-1" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "pub-rt"
  }

}

resource "aws_route_table_association" "ass-1" {
  route_table_id = aws_route_table.rt-1.id
  subnet_id      = aws_subnet.subnet-1.id

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.rt-1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}


resource "aws_security_group" "ssh" {
  name   = "allow ssh"
  vpc_id = aws_vpc.test.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  
  }
 
  egress {
    description = "all-allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

}

resource "aws_instance" "instance" {
  ami                         = "ami-0b72821e2f351e396"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet-1.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ssh.id]

  tags = {
    Name = "instnce"
  }
}