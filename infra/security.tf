# Define el tráfico permitido hacia y desde la EC2.
resource "aws_security_group" "ec2_publica" {
  name = "ec2-publica-sg"

  vpc_id = aws_vpc.main.id

  # Permite SSH solo desde el rango autorizado.
  ingress {
    description = "SSH para administracion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # Permite acceder a la web por HTTP desde Internet.
  ingress {
    description = "HTTP para aplicacion web"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite todo el tráfico de salida IPv4.
  egress {
    description = "Salida a internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-publica-sg"
  }
}
