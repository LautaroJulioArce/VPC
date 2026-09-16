terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "publica" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-publica"
  }
}

resource "aws_subnet" "privada" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-privada"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "route-table-publica"
  }
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_security_group" "ec2_publica" {
  name = "ec2-publica-sg"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH para administracion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP para aplicacion web"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "vpc_lab" {
  key_name   = "vpc-lab-key"
  public_key = file(pathexpand(var.ssh_public_key_path))

  tags = {
    Name = "vpc-lab-key"
  }
}

resource "aws_instance" "publica" {
  ami           = "ami-007dd4cdc89d5d91d"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.publica.id

  vpc_security_group_ids = [
    aws_security_group.ec2_publica.id
  ]

  key_name = aws_key_pair.vpc_lab.key_name

  associate_public_ip_address = true

  tags = {
    Name = "ec2-publica"
  }
  #este bloque de código adjunta el perfil de instancia IAM a la instancia EC2, lo que permite que la instancia utilice SSM para administración remota y otras funcionalidades proporcionadas por AWS Systems Manager.
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name
}


# este recurso es para permitir que la instancia EC2 pueda usar SSM (AWS Systems Manager) para administración remota sin necesidad de abrir puertos adicionales

resource "aws_iam_role" "ec2_ssm" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

#este bloque de código adjunta la política de AmazonSSMManagedInstanceCore al rol IAM creado anteriormente, lo que permite a la instancia EC2 utilizar SSM para administración remota y otras funcionalidades proporcionadas por AWS Systems Manager.
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}
#en resumen, este bloque de código configura un proveedor de identidad OpenID Connect (OIDC) para GitHub Actions en AWS. Esto permite que los flujos de trabajo de GitHub Actions asuman un rol IAM en AWS y obtengan permisos temporales para interactuar con los recursos de AWS, como enviar comandos a instancias EC2 a través de SSM. La configuración incluye la URL del proveedor OIDC, la lista de clientes permitidos y las políticas que definen qué acciones pueden realizar los flujos de trabajo de GitHub Actions en AWS.
resource "aws_iam_role" "github_actions" {
  name = "github-actions-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:LautaroJulioArce@271591981/VPC@1322345932:ref:refs/heads/master"
        }
      }
    }]
  })
}

#este bloque de código define una política de IAM para el rol de GitHub Actions, otorgando permisos específicos para interactuar con AWS Systems Manager (SSM). La política permite a los flujos de trabajo de GitHub Actions enviar comandos a la instancia EC2 y obtener información sobre la ejecución de esos comandos. Esto facilita la administración remota y la automatización de tareas en la instancia EC2 desde los flujos de trabajo de GitHub Actions.
resource "aws_iam_role_policy" "github_actions_ssm" {
  name = "github-actions-ssm"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ssm:SendCommand"
        ]

        Resource = [
          aws_instance.publica.arn,
          "arn:aws:ssm:us-east-1::document/AWS-RunShellScript"
        ]
      },
      {
        Effect = "Allow"

        Action = [
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands"
        ]

        Resource = "*"
      }
    ]
  })
}

#creamos un repositorio de Amazon Elastic Container Registry (ECR) llamado "vpc-web". Este repositorio se utiliza para almacenar imágenes de contenedores Docker. La configuración incluye la mutabilidad de las etiquetas de imagen (permitiendo que las etiquetas puedan cambiar), la habilitación del escaneo de imágenes al hacer push (para detectar vulnerabilidades) y la asignación de etiquetas para identificar el recurso en AWS.
resource "aws_ecr_repository" "vpc_web" {
  name                 = "vpc-web"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "vpc-web"
  }
}

resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "github-actions-ecr"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]

        Resource = aws_ecr_repository.vpc_web.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_ecr" {
  name = "ec2-ecr-read"
  role = aws_iam_role.ec2_ssm.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]

        Resource = aws_ecr_repository.vpc_web.arn
      }
    ]
  })
}
