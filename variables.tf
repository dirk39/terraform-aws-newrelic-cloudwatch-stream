variable "create_newrelic_iam" {
  type        = bool
  description = "Controls if NewRelic IAM should be created"
  default     = true
}

variable "newrelic_iam_role_name" {
  type        = string
  description = "NewRelic IAM role name"
  default     = "NewRelicMonitoringRole"
}

variable "newrelic_iam_role_description" {
  type        = string
  description = "NewRelic IAM role description"
  default     = "Role used by NewRelic infrastructure to monitor the account"
}

variable "newrelic_iam_role_tags" {
  type        = map(any)
  description = "NewRelic IAM role tags"
  default     = {}
}

variable "newrelic_iam_role_aws_account_id" {
  type        = string
  description = "NewRelic AWS account id to trust"
  default     = "754728514883"
}

variable "newrelic_iam_role_license_key" {
  type        = string
  description = "NewRelic license key"
}

variable "newrelic_iam_enable_budget_monitoring" {
  type        = bool
  description = "Enable budget cost monitoring"
}