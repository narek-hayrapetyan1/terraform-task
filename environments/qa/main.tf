terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"
  tags   = local.common_tags
}

module "security_groups" {
  source    = "../../modules/security-groups"
  qa_vpc_id = module.vpc.vpc_id
  tags = local.common_tags
}

module "secrets" {
  source      = "../../modules/secrets"
  environment = local.common_env.ENVIRONMENT
  db_password = var.db_password
  tags = local.common_tags
}

module "log_groups" {
  source = "../../modules/cloudwatch/log-groups"

  log_groups = {
    "/ecs/transaction-queue-task" = 7
    "/ecs/file-monitor-task"      = 7
    "/ecs/agency-task"            = 7
    "/ecs/wms-feedback-task"      = 7
  }

  tags = local.common_tags

}

module "ecs_task_execution_iam" {
  source      = "../../modules/iam/ecs-task-execution"
  environment = local.common_env.ENVIRONMENT

  secrets_arns = [
    module.secrets.db_password_arn
  ]

  tags = local.common_tags
}

module "ecs_cluster" {
  source = "../../modules/ecs/cluster"
  environment = local.common_env.ENVIRONMENT
  tags = local.common_tags
}

module "eventbridge_iam" {
  source      = "../../modules/iam/eventbridge"
  environment = local.common_env.ENVIRONMENT
  cluster_arn = module.ecs_cluster.cluster_arn
  tags = local.common_tags
}

module "api_service_task" {
  source = "../../modules/ecs/task-definition"

  family         = "api-service"
  container_name = "api-service"

  image = var.ecs_image

  command = [
    "sh",
    "-c",
    "chmod +x ./bin/startup.sh && ./bin/startup.sh"
  ]

  container_port = 8080

  log_group_name = "/ecs/api-service"

  execution_role_arn = module.ecs_task_execution_iam.execution_role_arn
  task_role_arn      = module.ecs_task_execution_iam.task_role_arn

  environment = {
    ENVIRONMENT      = "qa"
    FAKE_UNKNOWN_UMC = "False"
    LOG_LEVEL        = "DEBUG"
    DB_URL           = "test-db.us-east-2.rds.amazonaws.com"
  }

  secrets = {
    DB_PASSWORD = module.secrets.db_password_arn
  }

  tags = local.resource_tags.api_service
}

module "transaction_queue_task" {
  source = "../../modules/ecs/task-definition"

  family              = "transaction-queue-task"
  container_name      = "transaction-queue-task"
  image               = var.ecs_image
  command             = ["python", "-m", "src.controllers.transaction_queue_controller"]
  log_group_name      = "/ecs/transaction-queue-task"
  execution_role_arn = module.ecs_task_execution_iam.execution_role_arn

  environment = local.common_env
  secrets = {
    DB_PASSWORD = module.secrets.db_password_arn
  }
  tags = local.resource_tags.transaction_queue_task

}

module "file_monitor_task" {
  source = "../../modules/ecs/task-definition"

  family         = "file-monitor-task"
  container_name = "file-monitor-task"
  image          = var.ecs_image

  command = [
    "python",
    "-m",
    "src.jobs.completed_file_monitor"
  ]

  log_group_name      = "/ecs/file-monitor-task"
  execution_role_arn = module.ecs_task_execution_iam.execution_role_arn
  task_role_arn      = module.ecs_task_execution_iam.task_role_arn

  environment = local.common_env
  secrets = {
    DB_PASSWORD = module.secrets.db_password_arn
  }
  tags = local.resource_tags.file_monitor_task
}

module "image_task" {
  source = "../../modules/ecs/task-definition"

  family         = "image-task"
  container_name = "image-task"
  image          = var.ecs_image

  command = [
    "python",
    "-m",
    "src.controllers.image_file_controller"
  ]

  log_group_name      = "/ecs/image-task"
  execution_role_arn = module.ecs_task_execution_iam.execution_role_arn
  task_role_arn      = module.ecs_task_execution_iam.task_role_arn

  environment = local.common_env

  secrets = {
    DB_PASSWORD = module.secrets.db_password_arn
  }
  tags = local.resource_tags.image_task
}

module "agency_task" {
  source = "../../modules/ecs/task-definition"

  family         = "agency-task"
  container_name = "agency-task"
  image          = var.ecs_image

  command = [
    "python",
    "-m",
    "src.controllers.agency_file_controller"
  ]

  log_group_name     = "/ecs/agency-task"
  execution_role_arn = module.ecs_task_execution_iam.execution_role_arn
  task_role_arn      = module.ecs_task_execution_iam.task_role_arn

  environment = local.common_env

  secrets = {
    DB_PASSWORD = module.secrets.db_password_arn
  }
  tags = local.resource_tags.agency_task
}

module "wms_feedback_task" {
  source = "../../modules/ecs/task-definition"

  family         = "wms-feedback-task"
  container_name = "wms-feedback-task"
  image          = var.ecs_image

  command = [
    "python",
    "-m",
    "src.controllers.wms_feedback_file_controller"
  ]

  log_group_name      = "/ecs/wms-feedback-task"
  execution_role_arn = module.ecs_task_execution_iam.execution_role_arn
  task_role_arn      = module.ecs_task_execution_iam.task_role_arn

  environment = local.common_env

  secrets = {
    DB_PASSWORD = module.secrets.db_password_arn
  }
  tags = local.resource_tags.wms_feedback_task
}

module "transaction_queue_schedule" {
  source = "../../modules/ecs/scheduled-task"

  name                    = "transaction-queue-task"
  cluster_arn             = module.ecs_cluster.cluster_arn
  task_definition_arn     = module.transaction_queue_task.task_definition_arn
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_id       = module.security_groups.ecs_sg_id
  eventbridge_role_arn    = module.eventbridge_iam.eventbridge_role_arn
  tags                    = local.resource_tags.transaction_queue_task
}

module "file_monitor_schedule" {
  source = "../../modules/ecs/scheduled-task"

  name                   = "file-monitor-schedule"
  cluster_arn             = module.ecs_cluster.cluster_arn
  task_definition_arn     = module.file_monitor_task.task_definition_arn
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_id       = module.security_groups.ecs_sg_id
  eventbridge_role_arn    = module.eventbridge_iam.eventbridge_role_arn
  tags                    = local.resource_tags.file_monitor_task

}

module "image_task_schedule" {
  source = "../../modules/ecs/scheduled-task"

  name                   = "image-task"
  cluster_arn             = module.ecs_cluster.cluster_arn
  task_definition_arn     = module.image_task.task_definition_arn
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_id       = module.security_groups.ecs_sg_id
  eventbridge_role_arn    = module.eventbridge_iam.eventbridge_role_arn
  tags                    = local.resource_tags.image_task
}

module "agency_task_schedule" {
  source = "../../modules/ecs/scheduled-task"

  name                   = "agency-task"
  cluster_arn             = module.ecs_cluster.cluster_arn
  task_definition_arn     = module.agency_task.task_definition_arn
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_id       = module.security_groups.ecs_sg_id
  eventbridge_role_arn    = module.eventbridge_iam.eventbridge_role_arn
  tags                    = local.resource_tags.agency_task
}

module "wms_feedback_task_schedule" {
  source = "../../modules/ecs/scheduled-task"

  name                   = "wms-feedback-task"
  cluster_arn             = module.ecs_cluster.cluster_arn
  task_definition_arn     = module.wms_feedback_task.task_definition_arn
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_id       = module.security_groups.ecs_sg_id
  eventbridge_role_arn    = module.eventbridge_iam.eventbridge_role_arn
  tags                    = local.resource_tags.wms_feedback_task

}

module "alb" {
  source = "../../modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_sg_id
  environment           = local.common_env.ENVIRONMENT
  tags                  = local.common_tags
}

module "ecs_service" {
  source = "../../modules/ecs/service"

  cluster_id           = module.ecs_cluster.cluster_id
  task_definition_arn  = module.api_service_task.task_definition_arn
  subnet_ids           = module.vpc.private_subnet_ids
  security_group_id    = module.security_groups.ecs_sg_id

  target_group_arn     = module.alb.target_group_arn
  listener_arn         = module.alb.listener_arn
  environment          = local.common_env.ENVIRONMENT
  tags                 = local.common_tags
}

