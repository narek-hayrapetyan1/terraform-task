resource "aws_vpc" "qa_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags       = merge(var.tags, { Name = "service-qa-vpc" })
}

resource "aws_subnet" "qa_private_subnet_1" {
  vpc_id            = aws_vpc.qa_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags              = merge(var.tags, { Name = "service-qa-public-subnet-1" })
}

resource "aws_subnet" "qa_private_subnet_2" {
  vpc_id            = aws_vpc.qa_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags              = merge(var.tags, { Name = "service-qa-public-subnet-2" })
}

resource "aws_subnet" "qa_public_subnet_1" {
  vpc_id            = aws_vpc.qa_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags              = merge(var.tags, { Name = "service-qa-private-subnet-1" })
}

resource "aws_subnet" "qa_public_subnet_2" {
  vpc_id            = aws_vpc.qa_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags              = merge(var.tags, { Name = "service-qa-private-subnet-2" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.qa_vpc.id

  tags   = merge(var.tags, { Name = "service-igw" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.qa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, { Name = "public-route-table" })
}

resource "aws_route_table_association" "qa_public_subnet_1" {
  subnet_id      = aws_subnet.qa_public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "qa_public_subnet_2" {
  subnet_id      = aws_subnet.qa_public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "eip_nat_1" {
  domain = "vpc"
  tags = merge(var.tags, { Name = "service-nat-1" })
}

resource "aws_eip" "eip_nat_2" {
  domain = "vpc"
  tags = merge(var.tags, { Name = "service-nat-2" })

}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.eip_nat_1.id
  subnet_id     = aws_subnet.qa_public_subnet_1.id

  tags = merge(var.tags, { Name = "service-eip-nat-1" })
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.eip_nat_2.id
  subnet_id     = aws_subnet.qa_public_subnet_2.id

  tags = merge(var.tags, { Name = "service-eip-nat-2" })
}

