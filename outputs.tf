output "newrelic_monitoring_role_arn" {
  description = "NewRelic monitoring role arn"
  value       = aws_iam_role.newrelic_monitoring_role.arn
}