provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.75.2"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "vstaslon"
    key    = "dev/cluster/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "state_lock"
  }
}

resource "aws_vpc" "vs_main" {
  cidr_block = var.cidr_block_vpc

  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "vs_igw" {
  vpc_id = aws_vpc.vs_main.id

  tags = {
    Name = "${var.project}-igw"
  }
}

resource "aws_subnet" "private-1a" {
  vpc_id            = aws_vpc.vs_main.id
  cidr_block        = var.cidr_block_subnet_private-1a
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.project}-private-1a"
   }
}

resource "aws_subnet" "private-1b" {
  vpc_id            = aws_vpc.vs_main.id
  cidr_block        = var.cidr_block_subnet_private-1b
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.project}-private-1b"
    }
}

resource "aws_subnet" "public-1a" {
  vpc_id                  = aws_vpc.vs_main.id
  cidr_block              = var.cidr_block_subnet_public-1a
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-1a"
    }
}

resource "aws_subnet" "public-1b" {
  vpc_id                  = aws_vpc.vs_main.id
  cidr_block              = var.cidr_block_subnet_public-1b
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-1b"
    }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.project}-eip_nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-1a.id

  tags = {
    Name = "${var.project}-nat"
  }

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vs_main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "${var.project}-private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vs_main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.vs_igw.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "${var.project}-public"
  }
}

resource "aws_route_table_association" "private-1a" {
  subnet_id      = aws_subnet.private-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-1b" {
  subnet_id      = aws_subnet.private-1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-1a" {
  subnet_id      = aws_subnet.public-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-1b" {
  subnet_id      = aws_subnet.public-1b.id
  route_table_id = aws_route_table.public.id
}

