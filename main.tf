/**
 * Creates an AWS Lambda function to stream RDS logs into CloudWatch Logs
 * on a scheduled interval using [truss-aws-tools](https://github.com/trussworks/truss-aws-tools).
 *
 * Creates the following resources:
 *
 * * IAM role for Lambda function to list and get logs for a
 *   defined RDS instance as well as writing those logs into a CloudWatch Logs stream.
 * * CloudWatch Event to trigger Lambda function on a schedule.
 * * AWS Lambda function to actually stream RDS logs into CloudWatch Logs.
 *
 * ## Usage
 *
 * ```hcl
 * module "rds-cloudwatch-logs" {
 *   source  = "trussworks/rds-cloudwatch-logs/aws"
 *   version = "1.0.0"
 *
 *   env_cloudwatch_logs_group  = "rds-app-staging"
 *   env_db_instance_identifier = "app-staging"
 *   env_start_time             = "1h"
 *
 *   environment       = "staging"
 *   interval_minutes  = 60
 *   s3_bucket         = "lambda-builds-us-west-2"
 *   version_to_deploy = "2.6"
 * }
 * ```
 */

locals {
  pkg  = "truss-aws-tools"
  name = "rds-cloudwatch-logs"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#
# IAM
#

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Allow creating and writing CloudWatch logs for Lambda function
# and to the RDS logs group
data "aws_iam_policy_document" "main" {
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name}-${var.environment}:*",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.env_cloudwatch_logs_group}:*",
    ]
  }

  # Allow describing and downloading RDS logs for a particular RDS instance
  statement {
    sid    = "DescribeAndDownloadDBLogFiles"
    effect = "Allow"

    actions = [
      "rds:DescribeDBLogFiles",
      "rds:DownloadDBLogFilePortion",
    ]

    resources = [
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${var.env_db_instance_identifier}",
    ]
  }
}

resource "aws_iam_role" "main" {
  name               = "lambda-${local.name}-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "main" {
  name = "lambda-${local.name}-${var.environment}"
  role = "${aws_iam_role.main.id}"

  policy = "${data.aws_iam_policy_document.main.json}"
}

#
# CloudWatch Logs
#

# Logs from the Lambda function
resource "aws_cloudwatch_log_group" "lambda" {
  # This name must match the lambda function name and should not be changed
  name              = "/aws/lambda/${local.name}-${var.environment}"
  retention_in_days = "${var.cloudwatch_logs_retention_days}"

  tags = {
    Name        = "${local.name}-${var.environment}"
    Environment = "${var.environment}"
  }
}

# RDS logs copied to CloudWatch Logs via the Lambda function
resource "aws_cloudwatch_log_group" "rds" {
  name              = "${var.env_cloudwatch_logs_group}"
  retention_in_days = "${var.cloudwatch_logs_retention_days}"

  tags = {
    Name        = "${local.name}-${var.environment}"
    Environment = "${var.environment}"
  }
}

/*

# Don't use lambda anymore, but use built-in functionality
# https://github.com/terraform-providers/terraform-provider-aws/pull/6829

#
# Lambda Function
#

resource "aws_lambda_permission" "main" {
  statement_id = "${local.name}-${var.environment}"

  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.main.function_name}"

  principal  = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.main.arn}"
}

resource "aws_lambda_function" "main" {
  depends_on = [
    "aws_cloudwatch_log_group.lambda",
    "aws_cloudwatch_log_group.rds",
  ]

  s3_bucket = "${var.s3_bucket}"
  s3_key    = "${local.pkg}/${var.version_to_deploy}/${local.pkg}.zip"

  function_name = "${local.name}-${var.environment}"
  role          = "${aws_iam_role.main.arn}"
  handler       = "${local.name}"
  runtime       = "go1.x"
  memory_size   = "${var.lambda_memory_size}"
  timeout       = "${var.lambda_timeout}"

  environment {
    variables = {
      CLOUDWATCH_LOGS_GROUP  = "${var.env_cloudwatch_logs_group}"
      DB_INSTANCE_IDENTIFIER = "${var.env_db_instance_identifier}"
      LAMBDA                 = "true"
      START_TIME             = "${var.env_start_time}"
    }
  }

  tags = {
    Name        = "${local.name}-${var.environment}"
    Environment = "${var.environment}"
  }
}

#
# CloudWatch Scheduled Event
#

resource "aws_cloudwatch_event_rule" "main" {
  name                = "${local.name}-${var.environment}"
  description         = "scheduled trigger for ${local.name}"
  schedule_expression = "rate(${var.interval_minutes} minutes)"
}

resource "aws_cloudwatch_event_target" "main" {
  rule = "${aws_cloudwatch_event_rule.main.name}"
  arn  = "${aws_lambda_function.main.arn}"
}

*/

