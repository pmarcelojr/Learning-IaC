provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc_prd" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc_prd.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc_prd.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.vpc_prd.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc_prd.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_instance" "webserver" {
  ami           = var.image
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet_a.id
}

resource "aws_db_instance" "banco" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = var.password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "dbsubnet"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

resource "aws_eip" "nat" {
  vpc = true

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_prd.id
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private_subnet_a.id

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table" "router" {
  vpc_id = aws_vpc.vpc_prd.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.router.id
}
