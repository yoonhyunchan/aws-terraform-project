locals {
  tags_for_kubernetes = {
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
  tags_for_public_lb = {
    "kubernetes.io/role/elb"	         = "1"
  }
  tags_for_private_lb = {
    "kubernetes.io/role/internal-elb"	 = "1"
  }
  selected_azs = [
    "${var.region}a",
    "${var.region}c"
  ]
}

resource "aws_vpc" "main" {
  cidr_block                = var.vpc_cidr
  enable_dns_support        = true # For Private Hosted Zone
  enable_dns_hostnames      = true # For Private Hosted Zone
  tags = {
    Name                    = "main-vpc"
  }
}

# Public Subnet (AZ : region-a, region-c)
resource "aws_subnet" "public_subnets" {
  count                   = length(local.selected_azs) # 2개의 AZ에 생성
  vpc_id                  = aws_vpc.main.id
  # CIDR Block Assign: VPC CIDR(10.0.0.0/16) Subnet CIDR (10.0.1.0/24, 10.0.3.0/24)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2*(count.index) + 1)
  availability_zone       = local.selected_azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "public-subnet-${element(split(var.region, local.selected_azs[count.index]), 1)}" # ex: public-subnet-a
    },
    local.tags_for_kubernetes,
    local.tags_for_public_lb
  )
}

resource "aws_subnet" "private_subnets" {
  count                   = length(local.selected_azs) # 2개의 AZ에 생성
  vpc_id                  = aws_vpc.main.id
  # CIDR Block Assign: VPC CIDR(10.0.0.0/16) Subnet CIDR (10.0.2.0/24, 10.0.4.0/24)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2*(count.index+1))
  availability_zone       = local.selected_azs[count.index]

  tags = merge(
    {
      Name = "private-subnet-${element(split(var.region, local.selected_azs[count.index]), 1)}" # 예: private-subnet-a
    },
    local.tags_for_kubernetes,
    local.tags_for_private_lb
  )
}

# Private Subnet
resource "aws_internet_gateway" "igw" {
  vpc_id                    = aws_vpc.main.id
  tags = {
    Name                    = "aws_internet_gateway"
  }
}

# EIP per AZ
resource "aws_eip" "nat" {
  count = length(local.selected_azs)
  domain = "vpc"
  tags = {
    Name = "nat-eip-${element(split(var.region, local.selected_azs[count.index]), 1)}"
  }
}

# NAT Gateway per AZ
resource "aws_nat_gateway" "nat" {
  count         = length(local.selected_azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "nat-gateway-${element(split(var.region, local.selected_azs[count.index]), 1)}"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Public Subnet Routing Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Private Subnet Routing Table
resource "aws_route_table" "private_rt" {
  count  = length(local.selected_azs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "private-route-table-${element(split(var.region, local.selected_azs[count.index]), 1)}"
  }
}

# Public Subnet Routing Table Association
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Private Subnet Routing Table Association
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}