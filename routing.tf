resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.stack-example-vpc.id

  tags = {
    Name = " cloudlingists VPC Gateway"
  }
}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.stack-example-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "cloudlingists Public Subnet Route"
  }
}
