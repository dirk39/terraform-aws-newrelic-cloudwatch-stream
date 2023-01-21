data "aws_caller_identity" "current" {}

locals {
  datacenters = {
    "US" = "https://aws-api.newrelic.com/cloudwatch-metrics/v1"
    "EU" = "https://aws-api.eu01.nr-data.net/cloudwatch-metrics/v1"
  }
}

### IAM ###
resource "aws_iam_role" "newrelic_monitoring_role" {
  name               = var.role_name
  description        = var.role_description
  assume_role_policy = data.aws_iam_policy_document.newrelic_monitoring_role_policy.json
  tags               = var.role_tags
}

resource "aws_iam_role_policy_attachment" "newrelic_monitoring_role_readonly" {
  role       = aws_iam_role.newrelic_monitoring_role.id
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "newrelic_monitoring_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.newrelic_aws_account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.newrelic_account_number]
    }
  }
}

# Cost explorer
resource "aws_iam_role_policy" "newrelic_monitoring_role_cost" {
  count  = var.enable_budget_monitoring ? 1 : 0
  name   = "BudgetPolicy"
  role   = aws_iam_role.newrelic_monitoring_role.id
  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "budgets:ViewBudget"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_s3_bucket" "s3_firehose_backup_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "s3_firehose_backup_bucket" {
  bucket = aws_s3_bucket.s3_firehose_backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_acl" "s3_firehose_backup_bucket" {
  bucket = aws_s3_bucket.s3_firehose_backup_bucket.id
  acl    = "private"
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_newrelic_metric_stream" {
  name        = var.firehose_stream_name
  destination = "http_endpoint"

  s3_configuration {
    role_arn           = aws_iam_role.firehose_newrelic_metric_stream.arn
    bucket_arn         = aws_s3_bucket.s3_firehose_backup_bucket.arn
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
  }

  http_endpoint_configuration {
    url                = local.datacenters[var.firehose_datacenter_region]
    name               = "New Relic"
    access_key         = var.newrelic_license_key
    buffering_size     = 1
    buffering_interval = 60
    role_arn           = aws_iam_role.firehose_newrelic_metric_stream.arn
    s3_backup_mode     = "FailedDataOnly"

    request_configuration {
      content_encoding = "GZIP"
    }
  }
}

## KINESIS ROLE
resource "aws_iam_role" "firehose_newrelic_metric_stream" {
  name               = "NewRelicFirehoseRole"
  assume_role_policy = data.aws_iam_policy_document.firehose_newrelic_metric_stream_assume_role.json
}

data "aws_iam_policy_document" "firehose_newrelic_metric_stream_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["firehose.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role_policy" "firehose_newrelic_metric_stream" {
  role   = aws_iam_role.firehose_newrelic_metric_stream.id
  policy = data.aws_iam_policy_document.firehose_newrelic_metric_stream_policy.json
}

data "aws_iam_policy_document" "firehose_newrelic_metric_stream_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.s3_firehose_backup_bucket.arn,
      "${aws_s3_bucket.s3_firehose_backup_bucket.arn}/*"
    ]
  }
}

### CLOUDWATCH STREAM ###
resource "aws_cloudwatch_metric_stream" "cw_metric_stream" {
  name          = var.cw_metric_stream_name
  role_arn      = aws_iam_role.cw_metric_stream.arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.firehose_newrelic_metric_stream.arn
  output_format = "opentelemetry0.7"

  dynamic "include_filter" {
    for_each = var.cw_metric_stream_filters
    content {
      namespace = include_filter.value
    }
  }
}

resource "aws_iam_role" "cw_metric_stream" {
  name               = "NewRelicMetricStreamRole"
  assume_role_policy = data.aws_iam_policy_document.cw_metric_stream_assume_role.json
}

data "aws_iam_policy_document" "cw_metric_stream_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["streams.metrics.cloudwatch.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role_policy" "metric_stream_to_firehose" {
  name = "FirehosePolicy"
  role = aws_iam_role.cw_metric_stream.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": "${aws_kinesis_firehose_delivery_stream.firehose_newrelic_metric_stream.arn}"
        }
    ]
}
EOF
}