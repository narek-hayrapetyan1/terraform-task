variable "log_groups" {
  description = "Map of log group names to retention days"
  type        = map(number)
}

variable "tags" {
  type    = map(string)
  default = {}
}
