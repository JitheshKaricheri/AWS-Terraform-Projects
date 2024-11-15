#  create a vpc

resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "my-vpc"
  }
}

#  create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  
}
#  create a subnet

resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pub-subnet"
  }
}

#  create route table

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}
  
#  route table association

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.route-table.id
}

#  create a security group

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "allow_tls"
  }
}

#  network interface

resource "aws_network_interface" "nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_tls.id]

  attachment {
    instance     = aws_instance.web.id
    device_index = 1
  }
}
## elastic ip

resource "aws_eip" "lb" {
  instance = aws_instance.web.id
  domain   = "vpc"
}

# instance

resource "aws_instance" "web" {
  ami           = "ami-08a0d1e16fc3f61ea"
  instance_type = "t2.micro"
  key_name = "jr"

  tags = {
    Name = "HelloWorld"
  }

user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install httpd -y
            sudo systemctl start httpd
            sudo systemctl enable httpd
            sudo bash -c 'server > /var/www/html/index.html'
            EOF

}


