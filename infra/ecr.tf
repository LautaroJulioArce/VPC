# Almacena las imágenes Docker de la aplicación.
resource "aws_ecr_repository" "vpc_web" {
  name                 = "vpc-web"
  image_tag_mutability = "MUTABLE"

  # Activa el escaneo de vulnerabilidades al subir imágenes.
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "vpc-web"
  }
}

# Permite a GitHub Actions autenticarse en ECR y subir imágenes al repositorio.
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

# Permite a la EC2 autenticarse en ECR y descargar imágenes del repositorio.
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
