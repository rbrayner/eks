## VPC
resource "aws_vpc" "eks" {
    cidr_block = "10.10.0.0/16"
}

## IGW
resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id
}

## Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks.id
  }
}

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.eks.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.10.10.0/24"

  tags = {
    Name = "EKS Demo Public"
  }

  depends_on = [aws_internet_gateway.eks]
}

resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.10.20.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "EKS Demo Private A"
  }

  depends_on = [aws_internet_gateway.eks]
}

resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.10.30.0/24"
 availability_zone = "us-east-1b"
 
  tags = {
    Name = "EKS Demo Private B"
  }

  depends_on = [aws_internet_gateway.eks]
}

resource "aws_network_acl_association" "public" {
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

## Nat Gateway

resource "aws_eip" "eip" {
  vpc      = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.eks]
}