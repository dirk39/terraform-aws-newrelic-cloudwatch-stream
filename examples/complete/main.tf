provider "aws" {
  region = "eu-west-1"
}

module "newrelic_integration" {
  source = "../.."

  newrelic_account_number  = "123"
  newrelic_license_key     = "456"
  enable_budget_monitoring = true
  s3_bucket_name           = "newrelic-firehose-backup-bucket"

  firehose_stream_name       = "FirehoseStreamToNewRelic"
  firehose_datacenter_region = "EU"
  cw_metric_stream_name      = "CloudWatchMetricStreamNR"
  cw_metric_stream_filters = [
    "AWS/EC2",
    "AWS/EBS",
    "AWS/RDS"
  ]
}