variable "tags" {
  type        = map(any)
  description = "Default tags to use"
  default     = {}
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "s3_bucket_module_version" {
  type        = string
  description = "Default tags to use"
}

variable "newrelic_license_key" {
  type        = string
  description = "NewRelic license key"
  sensitive   = true
}