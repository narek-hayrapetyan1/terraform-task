output "log_group_names" {
  description = "Map of created CloudWatch log group names"
  value = {
    for k, v in aws_cloudwatch_log_group.cloudwatch_log_group :
    k => v.name
  }
}