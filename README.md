<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Creates an AWS Lambda function to stream RDS logs into CloudWatch Logs
on a scheduled interval using [truss-aws-tools](https://github.com/trussworks/truss-aws-tools).

Creates the following resources:

* IAM role for Lambda function to list and get logs for a
  defined RDS instance as well as writing those logs into a CloudWatch Logs stream.
* CloudWatch Event to trigger Lambda function on a schedule.
* AWS Lambda function to actually stream RDS logs into CloudWatch Logs.

## Usage

```hcl
module "rds_cloudwatch_logs" {
  source = "../../modules/aws-rds-cloudwatch-logs"

  env_cloudwatch_logs_group  = "rds-app-staging"
  env_db_instance_identifier = "app-staging"
  env_start_time             = "1h"

  environment       = "staging"
  interval_minutes  = 60
  s3_bucket         = "lambda-builds-us-west-2"
  version_to_deploy = "2.6"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cloudwatch\_logs\_retention\_days | Number of days to keep logs in AWS CloudWatch. | string | `"90"` | no |
| env\_cloudwatch\_logs\_group | The CloudWatch Log group name where the RDS logs will be streamed. | string | n/a | yes |
| env\_db\_instance\_identifier | The RDS database instance identifier. | string | n/a | yes |
| env\_start\_time | The log file start time. Currently support "1h" for the past hour and "1d" for the past day. | string | n/a | yes |
| environment | Environment tag, e.g prod. | string | n/a | yes |
| interval\_minutes | How often to run the Lambda function in minutes. | string | `"60"` | no |
| lambda\_memory\_size | Amount of memory in MB your Lambda Function can use at runtime. | string | `"128"` | no |
| lambda\_timeout | The amount of time your Lambda Function has to run in seconds. | string | `"60"` | no |
| s3\_bucket | The name of the S3 bucket used to store the Lambda builds. | string | n/a | yes |
| version\_to\_deploy | The version the Lambda function to deploy. | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
