output "alb_sg_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb_allow_http.id
}
output "ecs_sg_id" {
  description = "Security group ID for the ECS service"
  value       = aws_security_group.ecs_allow_alb.id
}
output "secretsmanager_endpoint_sg_id" {
  description = "Security group ID for the Secret Manager endpoint"
  value       = aws_security_group.secretsmanager_endpoint.id
}