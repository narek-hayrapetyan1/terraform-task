resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  name                = var.name
  schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "ecs" {
  rule     = aws_cloudwatch_event_rule.cloudwatch_event_rule.name
  arn      = var.cluster_arn
  role_arn = var.eventbridge_role_arn

  ecs_target {
    launch_type         = "FARGATE"
    task_definition_arn = var.task_definition_arn
    task_count          = 1

    network_configuration {
      subnets         = var.subnet_ids
      security_groups = [var.security_group_id]
      assign_public_ip = false
    }
  }
}
