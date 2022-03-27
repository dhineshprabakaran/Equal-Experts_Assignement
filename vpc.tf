# Creating VPC,name, CIDR and Tags
resource "aws_vpc" "dev" {
  cidr_block           = "172.20.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "dev"
  }
}

# Creating Public Subnet in VPC
resource "aws_subnet" "dev-public" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "172.20.10.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "dev-public"
  }
}
# Creating Private Subnet in VPC

resource "aws_subnet" "dev-private" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "172.20.20.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "dev-private"
  }
}

# Creating Internet Gateway in AWS VPC
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev"
  }
}

# Creating Route Tables for Internet gateway
resource "aws_route_table" "dev-public" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }

                                                                                                                                                                                         1,0-1         Top
  tags = {
    Name = "public-route-table"
  }
}

# Creating Route Associations public subnets
resource "aws_route_table_association" "dev-public-1-a" {
  subnet_id      = aws_subnet.dev-public.id
  route_table_id = aws_route_table.dev-public.id
}


# Creating Nat Gateway
resource "aws_eip" "nat" {
  vpc = true
  depends_on =  [aws_internet_gateway.dev-igw]
  tags = {
    Name = "NAT Gateway EIP"
 }
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.dev-public.id
  depends_on    = [aws_internet_gateway.dev-igw]
}

# Add routes for VPC
resource "aws_route_table" "dev-private-vpc" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "dev-private-1"
  }
}


# Creating route associations for private Subnets
resource "aws_route_table_association" "dev-private-rt" {
  subnet_id      = aws_subnet.dev-private.id
  route_table_id = aws_route_table.dev-private-vpc.id
}


#Creating EC2 instances in public subnets
resource "aws_instance" "public_inst" {
  ami           = "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.dev-public.id}"
  key_name = "25032022"
                                    count = 1
  associate_public_ip_address = true
  tags = {
    Name = "public_inst"
  }
}

#Creating EC2 instances in private subnets
resource "aws_instance" "private_inst" {
  ami           = "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.dev-private.id}"
  key_name = "25032022"
  count = 1
  associate_public_ip_address = false
  tags = {
    Name = "private_inst"
  }
}
                                                                                                                                                                                         126,1         Bot

