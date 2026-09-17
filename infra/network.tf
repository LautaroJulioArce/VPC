# Crea la red principal que agrupa los recursos del proyecto.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Crea la subnet para los recursos con acceso directo a Internet.
resource "aws_subnet" "publica" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-publica"
  }
}

# Crea una subnet sin una ruta directa a Internet.
resource "aws_subnet" "privada" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-privada"
  }
}

# Conecta la VPC con Internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Define las rutas de la subnet pública.
resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id

  # Envía el tráfico externo al Internet Gateway.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "route-table-publica"
  }
}

# Asocia la subnet pública con su tabla de rutas.
resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}
