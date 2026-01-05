resource "aws_ecs_cluster" "ecs_cluster" {
  name = "service-cluster"

  tags = merge(var.tags, { Name = "service_ecs_cluster" })
}