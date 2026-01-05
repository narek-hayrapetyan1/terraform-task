locals {
  common_env = {
    ENVIRONMENT        = "qa"
    FAKE_UNKNOWN_UMC   = "False"
    LOG_LEVEL          = "DEBUG"
    DB_URL             = "test-db.us-east-2.rds.amazonaws.com"
  }

  common_tags = {
    Environment = "qa"
    Project     = "service"
    Owner       = "qa-team"
  }

  resource_tags = {
    api_service            = merge(local.common_tags, { Name = "service-qa-api-service" })
    transaction_queue_task = merge(local.common_tags, { Name = "transaction-queue-task" })
    file_monitor_task      = merge(local.common_tags, { Name = "file-monitor-task" })
    agency_task            = merge(local.common_tags, { Name = "agency-task" })
    wms_feedback_task      = merge(local.common_tags, { Name = "wms-feedback-task" })
    image_task             = merge(local.common_tags, { Name = "image-task" })
  }
}