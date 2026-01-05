output "db_password_arn" {
  value       = aws_secretsmanager_secret.db_password.arn
  description = "ARN of DB password secret"
}