output "eventbridge_role_arn" {
  description = "IAM role ARN used by EventBridge to run ECS tasks"
  value       = aws_iam_role.eventbridge_ecs.arn
}
