resource "aws_iam_role" "eventbridge_ecs" {
  name = "eventbridge-ecs-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = "eventbridge_ecs_role" })

}

resource "aws_iam_policy" "eventbridge_ecs_policy" {
  name = "eventbridge-ecs-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecs:RunTask",
        "iam:PassRole"
      ]
      Resource = "*"
    }]
  })

  tags = merge(var.tags, { Name = "eventbridge_ecs_policy" })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.eventbridge_ecs.name
  policy_arn = aws_iam_policy.eventbridge_ecs_policy.arn
}
