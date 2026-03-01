resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags       = { Name = var.name }
}

resource "aws_subnet" "master_subnet" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 10)
  availability_zone       = var.az1
  map_public_ip_on_launch = true
  tags = { 
    Name = "${var.name}-master"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/kubernetes" = "owned"
  } 
}

resource "aws_subnet" "worker_subnet" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 20)
  availability_zone       = var.az2
  map_public_ip_on_launch = true
  tags = { 
    Name = "${var.name}-worker" 
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-rt" }
}

resource "aws_route_table_association" "master" {
  subnet_id      = aws_subnet.master_subnet.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route_table_association" "worker" {
  subnet_id      = aws_subnet.worker_subnet.id
  route_table_id = aws_route_table.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

resource "aws_route" "default_internet" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}