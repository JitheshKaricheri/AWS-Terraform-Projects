# create vpc
resource "aws_vpc" "myvpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
      Name = "myterravpc"
    }
  
}

# create public subnet

resource "aws_subnet" "pubsub" {
vpc_id = aws_vpc.myvpc.id
cidr_block = "10.0.1.0/24"

}

# create private subnet

resource "aws_subnet" "prv-sub" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.2.0/24"
  
}

# create internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

}

# create public rt

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.myvpc.id

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

}

#  public rt association

resource "aws_route_table_association" "pub-ass" {
    subnet_id = aws_subnet.pubsub.id
    route_table_id = aws_route_table.pub-rt.id
  
}

resource "aws_instance" "pub" {
    
  
}
  

