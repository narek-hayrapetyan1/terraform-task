variable "cluster_id" {}
variable "task_definition_arn" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "target_group_arn" {}
variable listener_arn {}
variable "environment" {}
variable "tags" {
  type    = map(string)
  default = {}
}

