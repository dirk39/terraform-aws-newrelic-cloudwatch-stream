variable "role_name" {
  type        = string
  description = "NewRelic IAM role name"
  default     = "NewRelicMonitoringRole"
}

variable "role_description" {
  type        = string
  description = "NewRelic IAM role description"
  default     = "Role used by NewRelic infrastructure to monitor the account"
}

variable "role_tags" {
  type        = map(any)
  description = "NewRelic IAM role tags"
  default     = {}
}

variable "newrelic_aws_account_id" {
  type        = string
  description = "NewRelic AWS account id to trust"
  default     = "754728514883"
}

variable "newrelic_account_number" {
  type        = string
  description = "Newrelic account number to send data"
}

variable "newrelic_license_key" {
  type        = string
  description = "NewRelic license key"
}

variable "enable_budget_monitoring" {
  type        = bool
  description = "Enable budget cost monitoring"
  default     = true
}

variable "s3_bucket_name" {
  type        = string
  description = "Firehose S3 backup bucket name"
}

variable "firehose_stream_name" {
  type        = string
  description = "Firehose stream name"
}

variable "firehose_datacenter_region" {
  type        = string
  description = "Firehose datacenter region. Valid values are EU and US"
}

variable "cw_metric_stream_name" {
  type        = string
  description = "CloudWatch metric stream name"
}

variable "cw_metric_stream_filters" {
  type        = list(any)
  description = "List of namespaces to include. If omitted, exports all metrics"
  default     = []
}