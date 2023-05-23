resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.namespace}-${var.project_name}-${var.environment}"
  }
}

resource "aws_security_group" "main" {
  name        = "${var.namespace}-${var.project_name}-${var.environment}"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Subnets
resource "aws_subnet" "main" {
  for_each = local.regions

  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.${each.key}.0/24"

  map_public_ip_on_launch = true
  availability_zone       = each.value
}

resource "aws_route_table_association" "main" {
  for_each = aws_subnet.main

  subnet_id      = each.value.id
  route_table_id = aws_route_table.main.id
}
