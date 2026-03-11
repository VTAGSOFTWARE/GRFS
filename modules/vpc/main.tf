locals {

  vpc_name = "${var.name}-vpc"

  common_tags = merge(
    {
      Name = local.vpc_name
    },
    var.tags
  )

  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = local.common_tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.name}-igw" })
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index % length(var.azs)]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${var.name}-public-subnet-${count.index + 1}" })
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(local.common_tags, { Name = "${var.name}-private-subnet-${count.index + 1}" })
}

# Isolated Subnets (for RDS)
resource "aws_subnet" "isolated" {
  count             = length(var.isolated_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(local.common_tags, { Name = "${var.name}-isolated-subnet-${count.index + 1}" })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.common_tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT: EIP(s)
resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"

  tags = merge(local.common_tags, { Name = "${var.name}-nat-eip-${count.index + 1}" })
}

resource "aws_nat_gateway" "this" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id

  # Single NAT -> first public subnet
  # Multi NAT  -> one per AZ (aligned by index)
  subnet_id = var.single_nat_gateway ? aws_subnet.public[0].id : aws_subnet.public[count.index].id

  tags = merge(local.common_tags, { Name = "${var.name}-nat-${count.index + 1}" })

  depends_on = [aws_internet_gateway.this]
}

# Private Route Tables (either one shared or per AZ)
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 1
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.name}-private-rt-${count.index + 1}" })
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? length(aws_route_table.private) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count     = length(aws_subnet.private)
  subnet_id = aws_subnet.private[count.index].id

  # Map subnet to RT:
  # - single NAT: all to RT[0]
  # - multi NAT: map by AZ index
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index % length(var.azs)].id
}

# Isolated Route Table (NO internet, NO NAT)
resource "aws_route_table" "isolated" {
  count  = length(aws_subnet.isolated) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.name}-isolated-rt" })
}

resource "aws_route_table_association" "isolated" {
  count          = length(aws_subnet.isolated)
  subnet_id      = aws_subnet.isolated[count.index].id
  route_table_id = aws_route_table.isolated[0].id
}
