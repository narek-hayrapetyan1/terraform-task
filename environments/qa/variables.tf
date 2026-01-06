variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "DB password(sensitive)"
  type        = string
  sensitive   = true
}

variable "ecs_image" {
  description = "ECR image for all ECS tasks"
  type        = string
  default = "040067931830.dkr.ecr.us-east-2.amazonaws.com/api-service:latest"
}