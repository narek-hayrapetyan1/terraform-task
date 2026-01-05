variable "family" {}
variable "container_name" {}
variable "image" {}
variable "command" {
  type = list(string)
}
variable "log_group_name" {}
variable "execution_role_arn" {}
variable "task_role_arn" {
  default = null
}
variable "environment" {
  type = map(string)
}
variable "secrets" {
  type = map(string)
}
variable "container_port" {
  type    = number
  default = null
}
variable "tags" {
  type    = map(string)
  default = {}
}
