variable "environment" {
  type        = string
  description = "Environment name"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  type        = string
  description = "Security Group ID"
}

variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "tags" {
  type    = map(string)
  default = {}
}

