resource "aws_secretsmanager_secret" "db_password" {
  name = "db-password-${var.environment}"

  tags = merge(var.tags, { Name = "db_password"})
}

resource "aws_secretsmanager_secret_version" "db_password_value" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}