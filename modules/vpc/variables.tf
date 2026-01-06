variable "tags" {
  type    = map(string)
  default = {}
}
variable "region" {
  type = string
  description = "region name"
}
variable "vpc_endpoint_sg_id" {}