variable "qa_vpc_id" {
  description = "QA VPC ID"
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}
