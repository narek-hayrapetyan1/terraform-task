output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "listener_arn" {
  description = "ARN of the HTTP listener (port 80)"
  value       = aws_lb_listener.http.arn
}

output "target_group_arn" {
  description = "ARN of the target group for api-service"
  value       = aws_lb_target_group.api.arn
}