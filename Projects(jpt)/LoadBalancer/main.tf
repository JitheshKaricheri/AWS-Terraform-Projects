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
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "terra-vpc"
  }
}

#Creating Public Subnet1
resource "aws_subnet" "public-sub" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/25"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "PUBLIC-sub"
  }
}

#Creating Public Subnet2
resource "aws_subnet" "public-sub-2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.128/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "PUBLIC-sub-2"
  }

}

#Creating Private Subnet
resource "aws_subnet" "private-sub" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.192/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "private-sub"
  }
}

#Creating Public Route Table
resource "aws_route_table" "pbrt" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "terra-pub-rt"
  }
}

#Creating Private Route Table
resource "aws_route_table" "pvrt" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "terra-prt-rt"
  }
}

#Public Route Assosiation Of Subnet1
resource "aws_route_table_association" "pub-ass" {
  route_table_id = aws_route_table.pbrt.id
  subnet_id      = aws_subnet.public-sub.id
}

#Public Route Assosiation Of Subnet2
resource "aws_route_table_association" "pub-ass-2" {
  route_table_id = aws_route_table.pbrt.id
  subnet_id      = aws_subnet.public-sub-2.id
}

#Private Route Assosiation Of Subnet
resource "aws_route_table_association" "pvrt-ass" {
  route_table_id = aws_route_table.pvrt.id
  subnet_id      = aws_subnet.private-sub.id
}

#Creating Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "terra-IGW"
  }
}

#Attaching Internet Gateway To Public Route
resource "aws_route" "route-1" {
  route_table_id         = aws_route_table.pbrt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

#Creating NAT Gateway
resource "aws_eip" "nat_eip" {
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-sub.id

}
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.pvrt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id

}
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "terra-sg"
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
  ami             = "ami-0ba9883b710b05ac6"
  instance_type   = "t2.micro"
  key_name        = "keypair"
  security_groups = [aws_security_group.sg.id]
  subnet_id       = aws_subnet.public-sub.id
  user_data       = file("bastion.sh")
}
resource "aws_instance" "priv-inst" {
  ami             = "ami-0ba9883b710b05ac6"
  instance_type   = "t2.micro"
  key_name        = "keypair"
  security_groups = [aws_security_group.sg.id]
  subnet_id       = aws_subnet.private-sub.id
}
resource "aws_lb" "alb" {
  name = "my-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg.id]
  subnets = [aws_subnet.public-sub.id,aws_subnet.public-sub-2.id]

  enable_deletion_protection = false
  tags = {
    Name = "my-alb"
  }
}


#Creating a Target Group
resource "aws_lb_target_group" "target_group" {
  name = "my-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id

  health_check {
    interval = 30
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name = "my-target-group"
  }
}

#Creating a Listener
resource "aws_lb_listener" "Listener" {
 load_balancer_arn = aws_lb.alb.arn
 port = 80
 protocol = "HTTP"
 default_action {
   type = "forward"
   target_group_arn = aws_lb_target_group.target_group.arn
 }
}

#Register Instance With Target Group
resource "aws_alb_target_group_attachment" "pub_inst" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id = aws_instance.pub-inst.id
  port = 80
}

resource "aws_lb_target_group_attachment" "priv_inst" {
  target_group_arn = aws_lb_target_group.target_group.id
  target_id = aws_instance.priv-inst.id
  port = 80
}

