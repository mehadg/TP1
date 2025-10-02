#IAM User
resource "aws_iam_user" "chris" {
  name          = "chris-${var.cgid}"
  force_destroy = true

  tags = {
    Name = "cg-chris-${var.cgid}"
  }
}

resource "aws_iam_access_key" "chris" {
  user = aws_iam_user.chris.name
}

resource "aws_iam_policy" "chris_policy" {
  name        = "cg-chris-policy-${var.cgid}"
  description = "cg-chris-policy-${var.cgid}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "chris"
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "iam:List*",
          "iam:Get*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "cg-chris-policy-${var.cgid}"
  }
}

resource "aws_iam_user_policy_attachment" "chris_attachment" {
  user       = aws_iam_user.chris.name
  policy_arn = aws_iam_policy.chris_policy.arn
}

# Lambda Assume Roles
resource "aws_iam_role" "lambdaManager_role" {
  name        = "cg-lambdaManager-role-${var.cgid}"
  description = "CloudGoat Lambda manager role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          AWS = aws_iam_user.chris.arn
        }
        Effect = "Allow"
      }
    ]
  })

  tags = {
    Name = "cg-debug-role-${var.cgid}"
  }
}

resource "aws_iam_policy" "lambdaManager_policy" {
  name        = "cg-lambdaManager-policy-${var.cgid}"
  description = "cg-lambdaManager-policy-${var.cgid}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLimitedLambdaActions"
        Effect = "Allow"
        # Actions réduites aux opérations réellement nécessaires
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:UpdateFunctionCode"
        ]
        # Limiter aux fonctions Lambda portant ton préfixe (ou lister les ARNs exacts)
        Resource = [
          "arn:aws:lambda:${var.aws_region}:${var.account_id}:function:cg-*"
        ]
      },
      {
        Sid    = "AllowPassSpecificRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        # Autoriser PassRole uniquement pour le rôle d'exécution Lambda défini dans ce module
        Resource = [
          aws_iam_role.debug_role.arn
        ]
      }
    ]
  })

  tags = {
    Name = "cg-lambdaManager-policy-${var.cgid}"
  }
}


  tags = {
    Name = "cg-lambdaManager-policy-${var.cgid}"
  }
}

resource "aws_iam_role_policy_attachment" "lambdaManager_role_attachment" {
  role       = aws_iam_role.lambdaManager_role.name
  policy_arn = aws_iam_policy.lambdaManager_policy.arn
}

resource "aws_iam_role" "debug_role" {
  name        = "cg-debug-role-${var.cgid}"
  description = "CloudGoat debug role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  tags = {
    Name = "cg-debug-role-${var.cgid}"
  }
}

resource "aws_iam_role_policy_attachment" "debug_administrator_attachment" {
  role       = aws_iam_role.debug_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
