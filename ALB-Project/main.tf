resource "aws_launch_template" "template" {
  name_prefix   = "my-temp"
  image_id      = "ami-066784287e358dad1"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.instance-sg.id]

  }
  block_device_mappings {
    device_name = "dev/xvda"
    ebs {
      volume_size = 15
      volume_type = "gp2"
    }
  }

  block_device_mappings {
    device_name = "dev/xvdf"
    ebs {
      volume_size = 15
      volume_type = "gp2"
    }
  }

  user_data = filebase64("userdata.sh")
}


resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"

}

resource "aws_subnet" "private-sub-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.128/26"
  availability_zone = "us-east-1a"

}

resource "aws_subnet" "public-sub-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.192/26"
  availability_zone = "us-east-1b"

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id


}

resource "aws_eip" "eip" {
  domain = "vpc"

}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

 

}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_route_table" "priv-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id

  }
  
}

resource "aws_security_group" "instance-sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "lb-sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public-sub-2.id]

}

resource "aws_lb_target_group" "tg" {
  name        = "lb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn

  }

}
