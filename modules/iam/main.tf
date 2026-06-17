module "ecs_task_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 6.0"

  name        = "${var.tags.Project}-${var.tags.Environment}-ecs-task-policy"
  path        = "/"
  description = "Permissions for ECS application tasks"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Sid    = "SecretsManager"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.db_secret_arn
      },

      {
        Sid    = "DynamoDB"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arn
      },
    ]
  })

  tags = var.tags
}

module "ecs_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name = "${var.tags.Project}-${var.tags.Environment}-ecs-task-role"

  trust_policy_permissions = {
    ECS = {
      actions = [
        "sts:AssumeRole"
      ]
      principals = [
        {
          type = "Service"
          identifiers = [
            "ecs-tasks.amazonaws.com"
          ]
        }
      ]
    }
  }

  policies = {
    ECSApplication = module.ecs_task_policy.arn
  }

  tags = var.tags
}
