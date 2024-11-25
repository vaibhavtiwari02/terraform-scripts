
# Create a new VPC

resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = var.vpc-name
  }
}

# Create 2 public subnets
resource "aws_subnet" "public_subnet1" {
  cidr_block              = var.subnet-cidr[0]
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-public1"
  }
}

resource "aws_subnet" "public_subnet2" {
  cidr_block              = var.subnet-cidr[1]
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-public2"
  }
}

# Create 2 private subnets
resource "aws_subnet" "private_subnet1" {
  cidr_block        = var.subnet-cidr[2]
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}a"
  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-private1"
  }
}

resource "aws_subnet" "private_subnet2" {
  cidr_block        = var.subnet-cidr[3]
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}b"
  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-private2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-igw"
  }
}

# Attach the Internet Gateway to the VPC
resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}

# Create a route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-rt-public"
  }
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "public_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.main.id
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_gateway" {
  domain = "vpc"
}

# Create a NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on    = [aws_internet_gateway_attachment.main]
}

# Create a route table for the private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "${aws_vpc.main.tags["Name"]}-rt-private"
  }
}

# Associate the route table with the private subnets
resource "aws_route_table_association" "private_subnet1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private.id
}