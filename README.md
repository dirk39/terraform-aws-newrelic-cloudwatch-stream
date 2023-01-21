# terraform-aws-newrelic-cloudwatch-stream
This terraform module which creates the resources to connect an AWS account to NewRelic and share metrics through CloudWatch Metric Streams.

Made with love by [![Open Source Saturday](https://img.shields.io/badge/%E2%9D%A4%EF%B8%8F-open%20source%20saturday-F64060.svg)](https://www.meetup.com/it-IT/Open-Source-Saturday-Milano/)

## Usage
```hcl
module "newrelic_integration" {
  source = "dirk39/newrelic-cloudwatch-stream/aws"
  version = "1.0.0"

  newrelic_iam_role_license_key         = "123"
  newrelic_iam_enable_budget_monitoring = true
  s3_bucket_name                        = "newrelic-firehose-backup-bucket"

  firehose_stream_name       = "FirehoseStreamToNewRelic"
  firehose_datacenter_region = "EU"
  cw_metric_stream_name      = "CloudWatchMetricStreamNR"
  cw_metric_stream_filters = [
    "AWS/EC2",
    "AWS/EBS",
    "AWS/RDS"
  ]
}
```

## Inputs

### Required inputs
| Name | Description | Type |
|------|-------------|------|
| <a name="newrelic_iam_role_account_number"></a> [newrelic\_iam\_role\_account\_number](#newrelic\_iam\_role\_account\_number) | Newrelic account number to send data | `string` |
| <a name="newrelic_iam_role_license_key"></a> [newrelic\_iam\_role\_license\_key](#newrelic\_iam\_role\_license\_key) | NewRelic license key | `string` |
| <a name="cw_metric_stream_name"></a> [cw\_metric\_stream\_name](#cw\_metric\_stream\_name) | CloudWatch metric stream name | `string` |
| <a name="s3_bucket_name"></a> [s3\_bucket\_name](#s3\_bucket\_name) | Firehose S3 backup bucket name | `string` |
| <a name="firehose_stream_name"></a> [firehose\_stream\_name](#firehose\_stream\_name) | Firehose stream name | `string` |
| <a name="firehose_datacenter_region"></a> [firehose\_datacenter\_region](#firehose\_datacenter\_region) | Firehose datacenter region. Valid values are EU and US | `string` |


### Optional inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="newrelic_iam_role_name"></a> [newrelic\_iam\_role\_name](#newrelic\_iam\_role\_name) | NewRelic IAM role name | `string` | `"NewRelicMonitoringRole"` |  |
| <a name="newrelic_iam_role_description"></a> [newrelic\_iam\_role\_description](#newrelic\_iam\_role\_description) | NewRelic IAM role description | `string` | `"Role used by NewRelic infrastructure to monitor the account"` |
| <a name="newrelic_iam_role_tags"></a> [newrelic\_iam\_role\_tags](#newrelic\_iam\_role\_tags) | NewRelic IAM role tags | `map(string)` | {} |
| <a name="newrelic_iam_role_aws_account_id"></a> [newrelic\_iam\_role\_aws\_account\_id](#newrelic\_iam\_role\_aws\_account\_id) | NewRelic AWS account id to trust | `string` | 754728514883 |
| <a name="newrelic_iam_enable_budget_monitorings"></a> [newrelic\_iam\_enable\_budget\_monitoring](#newrelic\_iam\_enable\_budget\_monitoring) | Enable budget cost monitoring | `bool` | `true` |
| <a name="cw_metric_stream_filters"></a> [cw\_metric\_stream\_filters](#cw\_metric\_stream\_filters) | List of namespaces to include. If omitted, exports all metrics | `list(string)` | [] |