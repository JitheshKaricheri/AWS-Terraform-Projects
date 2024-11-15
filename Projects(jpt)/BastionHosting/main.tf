terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.60.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"

  tags = {
    name = "terr-vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/25"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    name = "public-sub"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.128/25"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "false"

  tags = {
    name = "prvt-sub"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    name = "pub-rt"
  }

}

resource "aws_route_table" "prv-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    name = "prv-rt"
  }


}

resource "aws_route_table_association" "pub-asso" {
  route_table_id = aws_route_table.pub-rt.id
  subnet_id      = aws_subnet.subnet-1.id
}

resource "aws_route_table_association" "prv-asso" {
  route_table_id = aws_route_table.prv-rt.id
  subnet_id      = aws_subnet.subnet-2.id
}



resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    name = "igw"
  }

}

resource "aws_route" "route-1" {
  route_table_id         = aws_route_table.pub-rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "terrra-sg"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_instance" "pub-inst" {
  ami             = "ami-0427090fd1714168b"
  instance_type   = "t2.micro"
  key_name        = "ubu"
  security_groups = [aws_security_group.sg.id]
  subnet_id       = aws_subnet.subnet-1.id
  user_data       = file("bastion.sh")
  tags = {
    name = "pub-instance"
  }
}

resource "aws_instance" "prv-inst" {
  ami             = "ami-03972092c42e8c0ca"
  instance_type   = "t2.micro"
  key_name        = "ubu"
  security_groups = [aws_security_group.sg.id]
  subnet_id       = aws_subnet.subnet-2.id

  tags = {
    name = "prv-instance"
  }
}
