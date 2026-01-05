variable "name" {}
variable "cluster_arn" {}
variable "task_definition_arn" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "eventbridge_role_arn" {}
variable "tags" {
  type    = map(string)
  default = {}
}

