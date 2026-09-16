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
