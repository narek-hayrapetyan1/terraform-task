resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  for_each = var.log_groups

  name              = each.key
  retention_in_days = each.value

  tags = merge(var.tags, { Name = "service-log-group" })
}