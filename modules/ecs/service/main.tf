resource "aws_ecs_service" "ecs_service" {
  name            = "api-service"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "api-service"
    container_port   = 8080
  }

  depends_on = [
    aws_ecs_service.ecs_service
  ]
}
