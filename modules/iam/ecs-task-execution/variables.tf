variable "environment" {
  type        = string
  description = "Environment name"
}

variable "secrets_arns" {
  type        = list(string)
  description = "Secrets ECS tasks are allowed to read"
}
variable "tags" {
  type    = map(string)
  default = {}
}
