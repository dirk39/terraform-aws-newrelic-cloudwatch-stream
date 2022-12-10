### IAM ###
resource "aws_iam_role" "newrelic_monitoring_role" {
  count              = var.create_newrelic_iam ? 1 : 0
  name               = var.newrelic_iam_role_name
  description        = var.newrelic_iam_role_description
  assume_role_policy = data.aws_iam_policy_document.newrelic_monitoring_role_policy.json
  tags               = var.newrelic_iam_role_tags
}

resource "aws_iam_role_policy_attachment" "newrelic_monitoring_role_readonly" {
  count      = var.create_newrelic_iam ? 1 : 0
  role       = aws_iam_role.newrelic_monitoring_role[0].id
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "newrelic_monitoring_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.newrelic_iam_role_aws_account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.newrelic_iam_role_license_key]
    }
  }
}

# Cost explorer
resource "aws_iam_role_policy" "newrelic_monitoring_role_cost" {
  count  = var.create_newrelic_iam && var.newrelic_iam_enable_budget_monitoring ? 1 : 0
  name   = "BudgetPolicy"
  role   = aws_iam_role.newrelic_monitoring_role[0].id
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


### CLOUDWATCH STREAM ###
# resource "aws_cloudwatch_metric_stream" "newrelic_metric_stream" {
#   name          = "NewRelicMetricStream"
#   role_arn      = aws_iam_role.newrelic_metric_stream_role.arn
#   firehose_arn  = aws_kinesis_firehose_delivery_stream.newrelic_metric_stream_fh.arn
#   output_format = "opentelemetry0.7"

#   include_filter {
#     namespace = "AWS/EC2"
#   }

#   include_filter {
#     namespace = "AWS/EBS"
#   }

#   include_filter {
#     namespace = "AWS/RDS"
#   }
# }

# resource "aws_iam_role" "newrelic_metric_stream_role" {
#   name = "NewRelicMetricStreamRole"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "streams.metrics.cloudwatch.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "metric_stream_to_firehose" {
#   name = "FirehosePolicy"
#   role = aws_iam_role.newrelic_metric_stream_role.id

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "firehose:PutRecord",
#                 "firehose:PutRecordBatch"
#             ],
#             "Resource": "${aws_kinesis_firehose_delivery_stream.newrelic_metric_stream_fh.arn}"
#         }
#     ]
# }
# EOF
# }

# ## KINESIS ROLE
# resource "aws_iam_role" "iam_kinesis_firehose_newrelic" {
#   name               = "NewRelicFirehoseRole"
#   description        = "Firehose role used by NewRelic to push metrics"
#   assume_role_policy = data.aws_iam_policy_document.kinesis_fh_assume_role.json
#   tags = merge(var.tags, {
#     name        = "NewRelicMonitoringRole"
#     description = "Role used by NewRelic infrastructure to monitor the account"
#   })
# }

# data "aws_iam_policy_document" "kinesis_fh_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       identifiers = ["firehose.amazonaws.com"]
#       type        = "Service"
#     }

#     condition {
#       test = "StringEquals"
#       values = [
#       data.aws_caller_identity.current.account_id]
#       variable = "sts:ExternalId"
#     }
#   }
# }

# resource "aws_iam_role_policy" "iam_kinesis_firehose_newrelic" {
#   role   = aws_iam_role.iam_kinesis_firehose_newrelic.id
#   policy = data.aws_iam_policy_document.iam_kinesis_firehose_newrelic_policy.json
# }

# data "aws_iam_policy_document" "iam_kinesis_firehose_newrelic_policy" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "s3:ListBucketMultipartUploads",
#       "s3:ListBucket",
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "s3:PutObject",
#       "s3:GetObject",
#       "s3:AbortMultipartUpload",
#       "s3:GetBucketLocation",
#     ]
#     resources = [
#       "arn:aws:logs:*:*:log-group:*",
#       module.newrelic_s3.s3_bucket_arn,
#       "${module.newrelic_s3.s3_bucket_arn}/*",
#     ]
#   }
# }
# ### FH
# resource "aws_kinesis_firehose_delivery_stream" "newrelic_metric_stream_fh" {
#   name        = "NewRelicMetricStreamFirehose"
#   destination = "http_endpoint"

#   s3_configuration {
#     role_arn           = aws_iam_role.iam_kinesis_firehose_newrelic.arn
#     bucket_arn         = module.newrelic_s3.s3_bucket_arn
#     buffer_size        = 10
#     buffer_interval    = 400
#     compression_format = "GZIP"
#   }

#   http_endpoint_configuration {
#     url                = "https://aws-api.eu01.nr-data.net/cloudwatch-metrics/v1"
#     name               = "New Relic"
#     access_key         = var.newrelic_license_key
#     buffering_size     = 1
#     buffering_interval = 60
#     role_arn           = aws_iam_role.iam_kinesis_firehose_newrelic.arn
#     s3_backup_mode     = "FailedDataOnly"

#     request_configuration {
#       content_encoding = "GZIP"
#     }
#   }
# }

# ### S3 -> rework without module
# module "newrelic_s3" {
#   source  = "terraform-aws-modules/s3-bucket/aws//"
#   version = "~> 3.4.0"

#   bucket = "${var.environment}-myreco-newrelic-bucket"
#   acl    = "private"
#   tags = merge(var.tags, {
#     name        = "${var.environment}-myreco-newrelic-bucket"
#     description = "Bucket to store failed pushed to NewRelic"
#   })

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
