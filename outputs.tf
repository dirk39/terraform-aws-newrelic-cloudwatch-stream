output "newrelic_monitoring_role_arn" {
  description = "NewRelic monitoring role arn"
  value       = try(aws_iam_role.newrelic_monitoring_role[0].arn, null)
}