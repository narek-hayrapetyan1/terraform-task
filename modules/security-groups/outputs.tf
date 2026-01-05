output "alb_sg_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb_allow_http.id
}

output "ecs_sg_id" {
  description = "Security group ID for the ECS service"
  value       = aws_security_group.ecs_allow_alb.id
}