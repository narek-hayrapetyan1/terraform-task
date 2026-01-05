resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.image
      command = length(var.command) > 0 ? var.command : null

      portMappings = var.container_port != null ? [{
        containerPort = var.container_port
        protocol      = "tcp"
      }] : []

      environment = [
        for k, v in var.environment : {
           name  = k
           value = v
        }
      ]

      secrets = [
        for k, v in var.secrets : {
          name      = k
          valueFrom = v
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = "us-east-2"
          awslogs-stream-prefix = var.container_name
        }
      }
    }
  ])
}
