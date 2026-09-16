


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
